terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket         = "rowan-2503-state-final"
    key            = "dev/terraform/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "rowan-2503-state-final"
  }
}

# vpc
module "vpc" {
  source               = "../modules/vpc"

  stage                = var.stage
  servicename          = var.servicename
  vpc_ip_range         = var.vpc_ip_range

  subnet_public_az1    = var.subnet_public_az1
  subnet_public_az2    = var.subnet_public_az2
  subnet_service_az1   = var.subnet_service_az1
  subnet_service_az2   = var.subnet_service_az2
  subnet_db_az1        = var.subnet_db_az1
  subnet_db_az2        = var.subnet_db_az2
  
  az                   = var.az
  tags                 = var.tags
}

# openvpn
module "openvpn" {
  source = "../modules/openvpn"

  openvpn_instance_type = "t3.micro"
  key_name              = "rowan-key"
  subnet_id             = module.vpc.public_subnet_id
  vpc_id                = module.vpc.vpc_id
  name                  = "openvpn-${var.stage}-${var.servicename}"
}

# rds
module "rds" {
  #default engin aurora-mysql8.0
  source       = "../modules/aurora"
  stage        = var.stage
  servicename  = var.servicename
  
  tags = var.tags
  rds_dbname = var.rds_dbname
#  sg_allow_ingress_list_aurora    = var.sg_allow_ingress_list_aurora
#  sg_allow_ingress_sg_list_aurora = concat([module.vpc.sg-ec2-comm.id, module.eks.eks_node_sg_id], var.sg_allow_list_aurora_sg_add)
  sg_allow_ingress_sg_list_aurora = [module.asg.asg_ec2_sg_id]
  network_vpc_id                  = module.vpc.vpc_id
  subnet_ids = [module.vpc.db-az1.id, module.vpc.db-az2.id]
  az           = var.az

  rds_instance_count = var.rds_instance_count

  kms_key_id = null
  depends_on = [module.vpc]
}

# asg
module "asg" {
  source        = "../modules/asg"
  stage         = var.stage
  servicename   = var.servicename
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  alb_security_group_id = module.alb.alb_sg_id
  vpc_id = module.vpc.vpc_id
  subnet_ids         = [module.vpc.service-az1.id, module.vpc.service-az2.id]
  target_group_arns  = [module.alb.alb_target_group_arn]
  openvpn_sg_id = module.openvpn.sg_id

  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  user_data     = local.user_data
  # wordpress를 위한 rds 설정
  rds_username = var.rds_username
  rds_password = module.rds.rds-random-password
  rds_dbname   = var.rds_dbname
  rds_endpoint = module.rds.endpoint
}

#alb
module "alb" {
  source      = "../modules/alb"
  stage       = var.stage
  servicename = var.servicename
  tags        = var.tags

  internal     = false
  subnet_ids   = [module.vpc.public-az1.id, module.vpc.public-az2.id]
  vpc_id       = module.vpc.vpc_id
  idle_timeout = "60"

  port         = "80"
  target_type  = "instance"

  hc_path                 = "/health"
  hc_healthy_threshold   = 2
  hc_unhealthy_threshold = 2

  sg_allow_comm_list = ["0.0.0.0/0"]

  # HTTPS 및 Route53 생략
  aws_s3_lb_logs_name = ""
  certificate_arn     = ""
  domain              = ""
  hostzone_id         = ""
}

locals {
  user_data = templatefile("../templates/user_data.sh.tpl", {
    rds_dbname   = var.rds_dbname
    rds_username = var.rds_username
    rds_password = module.rds.rds-random-password
    rds_endpoint = module.rds.endpoint
  })
}