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

tags = {
  Project = "terraform_final"
  Owner   = "Rowan"
}
