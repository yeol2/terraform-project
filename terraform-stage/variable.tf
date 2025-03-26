variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "servicename" {
  type    = string
  default = "terraform-rowan"
}

variable "tags" {
  type = map(string)
  default = {
    "name" = "terraform-final"
  }
}

# VPC Configuration
variable "az" {
  type    = list(any)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "vpc_ip_range" {
  type    = string
  default = "192.168.0.0/16"
}

variable "subnet_public_az1" {
  type    = string
  default = "192.168.10.0/24"
}
variable "subnet_public_az2" {
  type    = string
  default = "192.168.110.0/24"
}

variable "subnet_service_az1" {
  type    = string
  default = "192.168.20.0/24"
}
variable "subnet_service_az2" {
  type    = string
  default = "192.168.120.0/24"
}

variable "subnet_db_az1" {
  type    = string
  default = "192.168.30.0/24"
}
variable "subnet_db_az2" {
  type    = string
  default = "192.168.130.0/24"
}

# Instance Configuration
variable "ami" {
  type    = string
  default = "ami-062cddb9d94dcf95d"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "openvpn_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_ebs_size" {
  type    = number
  default = 30
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "key_name" {
  description = "Name of the key pair to use for EC2"
  type        = string
  default     = "keypair-full-master"
}

# RDS (DB) Configuration
variable "rds_dbname" {
  type    = string
  default = "rds-terraform"
}

variable "rds_instance_count" {
  type    = string
  default = "1"
}

# # KMS Configuration
# variable "rds_kms_arn" {
#   type    = string
#   default = "arn:aws:kms:ap-northeast-2:471112992234:key/1dbf43f7-1847-434c-bc3c-1beb1b86e480"  # 기본 KMS ARN
# }

# variable "ebs_kms_key_id" {
#   type    = string
#   default = "arn:aws:kms:ap-northeast-2:471112992234:key/43b0228d-0a06-465c-b25c-7480b07b5276"  # EBS용 기본 KMS ARN
# }


# ALB가 내부용인지 외부용인지 (false: 인터넷 공개)
variable "internal" {
  type    = bool
  default = false
}

# ALB가 배포될 서브넷 ID 목록
variable "subnet_ids" {
  type = list(string)
  default = []
}

# ALB의 idle timeout (기본 60초)
variable "idle_timeout" {
  type    = string
  default = "60"
}

variable "rds_username" {
  type    = string
  default = "admin"
}

