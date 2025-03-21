provider "aws" {
        region = "ap-northeast-2"
}

resource "aws_instance" "practice1" {
        ami = "ami-062cddb9d94dcf95d"
        instance_type = "t2.micro"

        tags = {
                name = "980516"
        }
}