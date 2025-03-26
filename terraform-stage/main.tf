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

module "openvpn" {
  source        = "../modules/openvpn"
  name          = "OpenVPN-Server"
  openvpn_instance_type = var.openvpn_instance_type
  key_name      = var.key_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public-az1.id
}