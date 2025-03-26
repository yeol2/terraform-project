variable "vpc_id" {}
variable "port" {
  type    = number
  default = 80
}
variable "web_ingress_cidrs" {
  type = list(string)
}
variable "tags" {
  type = map(string)
}
variable "stage" {}
