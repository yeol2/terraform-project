terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket         = "rowan-2503-state-final"
    key            = "dev/terraform/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "rowan-2503-state-final"
  }
}

provider "aws" {
  region = var.region
}
