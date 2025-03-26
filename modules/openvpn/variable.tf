variable "name" {
  description = "Name of the OpenVPN instance"
  type        = string
}

variable "openvpn_instance_type" {
  description = "Instance type for OpenVPN"
  type        = string
}

variable "key_name" {
  description = "SSH Key Pair for OpenVPN instance"
  type        = string
}

# modules/openvpn/variables.tf
variable "subnet_id" {
  description = "Subnet ID for OpenVPN instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

output "sg_id" {
  value = aws_security_group.openvpn_sg.id
}

