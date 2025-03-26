terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket         = "rowan-2503-state-final"
    key            = "prod/terraform/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "rowan-2503-state-final"
  }
}

# VPC 모듈 호출
module "vpc" {
  source = "../modules/vpc"

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

# SG 모듈 호출
module "sg" {
  source            = "../modules/sg"
  vpc_id            = module.vpc.vpc_id
  port              = 80
  web_ingress_cidrs = var.web_ingress_cidrs
  stage             = var.stage
  tags              = var.tags
}

# alb (ALB + EC2 + ASG + CW) 모듈 호출
module "alb" {
  source             = "../modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.service_subnet_ids

  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  deploy_message = "Hello from Terraform CI/CD!"

  web_sg_id = module.sg.web_sg_id
  alb_sg_id = module.sg.alb_sg_id
  alb_name  = var.alb_name

  stage = var.stage
  tags  = var.tags
}

#1