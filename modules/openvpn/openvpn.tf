# OpenVPN EC2 인스턴스 생성
resource "aws_instance" "openvpn" {
  ami           = "ami-09a093fa2e3bfca5af" # ✅ 고정된 openvpn ami id
  instance_type = var.openvpn_instance_type
  key_name      = var.key_name 
  vpc_security_group_ids = [aws_security_group.openvpn_sg.id]
  subnet_id = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "openvpn_sg" {
  name        = "${var.name}-sg"
  description = "Allow OpenVPN traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # OpenVPN Web UI
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # OpenVPN HTTPS
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] # OpenVPN UDP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



