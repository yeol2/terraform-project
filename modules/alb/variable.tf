variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "port" {
  type    = number
  default = 80
}
variable "deploy_message" {
  default = "Deployed via CI/CD"
}
variable "web_sg_id" {}
variable "alb_sg_id" {}
variable "alb_name" {}
variable "stage" {}
variable "tags" {
  type = map(string)
}
