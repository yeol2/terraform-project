provider "aws" {
        region = "ap-northeast-2"
        default_tags {
                tags = {
                        Name = "rowan-practice2"
                }
        }
}

resource "aws_instance" "webserver" {
        ami = "ami-062cddb9d94dcf95d"
        instance_type = "t2.micro"
        vpc_security_group_ids = [aws_security_group.webserver_sg.id]

        user_data = <<-EOF
                #!/bin/bash
                yum update && yum install -y busybox
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
}

resource "aws_security_group" "webserver_sg" {
        name = "webserver-sg-rowanN"
        ingress {
                from_port = 8080
                to_port = 8080
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
}
