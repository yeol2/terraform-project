variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
}
variable "stage" {
  type        = string
  description = "Environment name, e.g., dev or prod"
}

variable "servicename" {
  type        = string
  description = "Name of the service for tagging"
}
variable "az" {
  type        = list(string)
  description = "List of Availability Zones (e.g. [\"ap-northeast-2a\", \"ap-northeast-2c\"])"
}

# vpc cidr "192.168.0.0/16"
variable "vpc_ip_range" {
  type        = string
  description = "CIDR block for the VPC"
}

# public "192.168.10.0/24"
variable "subnet_public_az1" {
  type = string
}

# public "192.168.110.0/24"
variable "subnet_public_az2" {
  type = string
}

# private "192.168.20.0/24"
variable "subnet_service_az1" {
  type = string
}

#  private "192.168.120.0/24"
variable "subnet_service_az2" {
  type = string
}


#  db "192.168.30.0/24"
variable "subnet_db_az1" {
  type = string
}

#  db "192.168.130.0/24"
variable "subnet_db_az2" {
  type = string
}
