stage                = "prod"
region               = "ap-northeast-2"
servicename          = "terraform-rowan"

vpc_ip_range         = "10.10.0.0/16"
subnet_public_az1    = "10.10.1.0/24"
subnet_public_az2    = "10.10.2.0/24"
subnet_service_az1   = "10.10.3.0/24"
subnet_service_az2   = "10.10.4.0/24"
subnet_db_az1        = "10.10.5.0/24"
subnet_db_az2        = "10.10.6.0/24"
az = [ "ap-northeast-2a", "ap-northeast-2c" ]

tags = {
  Project = "terraform_final"
  Owner   = "Rowan"
}

# EC2 인스턴스 관련
ami_id         = "ami-062cddb9d94dcf95d"
instance_type  = "t3.micro"
key_name       = "keypair-full-master"

# ALB/SG
alb_name           = "web-alb"
web_ingress_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]