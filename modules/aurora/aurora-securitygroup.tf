# 📌 Aurora RDS 보안 그룹 생성
resource "aws_security_group" "sg-aurora" {
  name   = "aws-sg-${var.stage}-${var.servicename}-aurora-${var.dbname}"
  # 보안 그룹 이름 (예: "aws-sg-dev-myapp-aurora-mydb")

  vpc_id = var.network_vpc_id
  # 보안 그룹이 속할 VPC ID 지정 (Aurora RDS가 배치될 VPC)


  ingress {
    description = "Allow MySQL access from allowed CIDR blocks"
    from_port   = 3306  # MySQL 포트 (Aurora MySQL의 경우 3306)
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_ingress_list_aurora
    # 특정 CIDR 블록(예: "192.168.1.0/24")에서 Aurora RDS에 접근 허용
  }

  ingress {
    description = "Allow MySQL access from allowed Security Groups"
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = var.sg_allow_ingress_sg_list_aurora
    # 특정 보안 그룹에서 Aurora RDS 접근 허용 (예: "sg-0123456789abcdef0")
  }


  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # 모든 TCP 트래픽을 허용
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    # 모든 UDP 트래픽을 허용
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    # 모든 ICMP 트래픽을 허용 (핑 요청 가능)
  }

    tags = merge(tomap({
         Name =  "aws-sg-${var.stage}-${var.servicename}-aurora-${var.dbname}"}),
        var.tags)
  # 보안 그룹에 태그 적용 (예: "aws-sg-dev-myapp-aurora-mydb")

}
