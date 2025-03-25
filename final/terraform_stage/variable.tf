# variables.tf에 추가
variable "region" {
  type    = string
}

variable "stage" {
  type        = string
}

variable "servicename" {
  type        = string
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