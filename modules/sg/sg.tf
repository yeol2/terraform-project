resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.stage}"
  description = "Allow HTTP access to webserver"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "web-sg-${var.stage}" }, var.tags)
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.stage}"
  description = "Allow access to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "alb-sg-${var.stage}" }, var.tags)
}
