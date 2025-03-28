variable "stage" {
  description = "Deployment stage (e.g. dev, prod)"
  type        = string
}

variable "servicename" {
  description = "Service name for naming resources"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for launching EC2 instances"
  type        = list(string)
}

variable "target_group_arns" {
  description = "ALB target group ARNs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Initial desired instance count"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
}

variable "alb_security_group_id" {
  description = "Security Group ID of ALB that allows access to EC2 (ASG)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ASG and security group will be created"
  type        = string
}

variable "openvpn_sg_id" {
  description = "OpenVPN Security Group ID"
  type        = string
}