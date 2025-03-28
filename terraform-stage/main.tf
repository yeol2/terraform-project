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
  source        = "../modules/openvpn"
  name          = "OpenVPN-Server"
  openvpn_instance_type = var.instance_type
  key_name      = var.key_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public-az1.id
}


# rds
module "rds" {
  #default engin aurora-mysql8.0
  source       = "../modules/aurora"
  stage        = var.stage
  servicename  = var.servicename
  
  tags = var.tags
  rds_dbname = var.rds_dbname

  sg_allow_ingress_sg_list_aurora = [module.asg.asg_ec2_sg_id]
  network_vpc_id                  = module.vpc.vpc_id
  subnet_ids = [module.vpc.db-az1.id] #  module.vpc.db-az2.id c존 빼서 a존에만 생성되도록
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

  desired_capacity = 2
  max_size         = 4
  min_size         = 2
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
  certificate_arn     = "arn:aws:acm:ap-northeast-2:908027376495:certificate/6d1445a2-f28a-4d47-b2f6-5a700358cd94"
  domain              = ""
  hostzone_id         = ""
}

