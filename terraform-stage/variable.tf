# variables.tf에 추가
variable "region" {
  type = string
}

variable "stage" {
  type = string
}

variable "servicename" {
  type = string
}

variable "vpc_ip_range" {
  type = string
}

variable "subnet_public_az1" {
  type = string
}
variable "subnet_public_az2" {
  type = string
}

variable "subnet_service_az1" {
  type = string
}
variable "subnet_service_az2" {
  type = string
}

variable "subnet_db_az1" {
  type = string
}
variable "subnet_db_az2" {
  type = string
}

variable "az" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

# EC2 인스턴스 관련
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}

# ALB, ASG, SG 관련
variable "alb_name" {}
variable "web_ingress_cidrs" {
  type = list(string)
}