variable "stage" {
  type        = string
  description = "Environment name, e.g., dev or prod"
}

variable "servicename" {
  type        = string
  description = "Name of the service for tagging"
}

variable "vpc_ip_range" {
  type        = string
  description = "CIDR block for the VPC"
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
  type        = list(string)
  description = "List of Availability Zones (e.g. [\"ap-northeast-2a\", \"ap-northeast-2c\"])"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
}