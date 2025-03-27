# ALB 생성
resource "aws_lb" "alb" {
  name               = "aws-alb-${var.stage}-${var.servicename}"  # ALB 이름 (예: aws-alb-dev-myapp)
  internal           = var.internal  # 내부 로드 밸런서 여부 (true: 내부, false: 인터넷 공개)
  load_balancer_type = "application"  # ALB 유형 (Application Load Balancer)

  security_groups    = [aws_security_group.sg-alb.id]  # ALB에 적용할 보안 그룹
  subnets            = var.subnet_ids  # ALB가 배포될 서브넷 리스트

  enable_deletion_protection = false  # ALB 삭제 방지 활성화

  idle_timeout = var.idle_timeout  # ALB의 연결 유휴 시간 설정

  # ALB 접근 로그 설정 (S3에 저장)
  # access_logs {
  #   bucket  = var.aws_s3_lb_logs_name  # S3 버킷 이름
  #   prefix  = "aws-alb-${var.stage}-${var.servicename}"  # 로그 파일 접두사
  #   enabled = true  # ALB 로그 활성화
  # }

  tags = merge(tomap({
         Name = "aws-alb-${var.stage}-${var.servicename}"}), var.tags)
}

# HTTPS (443) 리스너 설정
# resource "aws_lb_listener" "lb-listener-443" {
#   load_balancer_arn = aws_lb.alb.arn  # ALB의 ARN
#   port              = "443"  # HTTPS 포트
#   protocol          = "HTTPS"  # HTTPS 프로토콜 사용
#   ssl_policy        = "ELBSecurityPolicy-2016-08"  # SSL 보안 정책
#   certificate_arn   = var.certificate_arn  # SSL 인증서 ARN (HTTPS 지원)

#   default_action {
#     type             = "forward"  # 기본 액션: 트래픽을 Target Group으로 전달
#     target_group_arn = aws_lb_target_group.target-group.arn  # 연결할 타겟 그룹
#   }

#   tags = var.tags
#   depends_on = [aws_lb_target_group.target-group]  # 타겟 그룹이 먼저 생성된 후 실행
# }

# HTTP (80) 리스너 설정 (자동 리디렉션)
# resource "aws_lb_listener" "lb-listener-80" {
#   load_balancer_arn = aws_lb.alb.arn  # ALB의 ARN
#   port              = "80"  # HTTP 포트
#   protocol          = "HTTP"  # HTTP 프로토콜 사용

#   default_action {
#     type = "redirect"  # 기본 액션: HTTPS로 리디렉트

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"  # 영구 리디렉트 (301)
#     }
#   }

#   tags = var.tags
# }

# 443 설정 안 해서 임시 사용
resource "aws_lb_listener" "lb-listener-80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }

  tags = var.tags
}


# Target Group 생성 (ALB가 트래픽을 전달할 대상)
resource "aws_lb_target_group" "target-group" {
  name     = "aws-alb-tg-${var.stage}-${var.servicename}"  # 타겟 그룹 이름
  port     = var.port  # 타겟 그룹 포트 (예: 80, 8080 등)
  protocol = "HTTP"  # 프로토콜 설정 (HTTP)
  vpc_id   = var.vpc_id  # 타겟 그룹이 속할 VPC ID
  target_type = var.target_type  # 인스턴스, IP 또는 Lambda 지정 가능

  # 헬스 체크 설정
  health_check {
    path                = var.hc_path  # 헬스 체크 경로 (예: "/health")
    healthy_threshold   = var.hc_healthy_threshold  # 정상 상태로 간주할 요청 수
    unhealthy_threshold = var.hc_unhealthy_threshold  # 비정상 상태로 간주할 요청 수
    interval            = 30                              # 체크 간격 (초)
    timeout             = 5                               # 응답 타임아웃 (초)
    matcher             = "200"                           # 기대 응답 코드
  }

  tags = merge(tomap({
         Name = "aws-alb-tg-${var.stage}-${var.servicename}"}), var.tags)
}

# ALB 보안 그룹 설정
resource "aws_security_group" "sg-alb" {
  name   = "aws-sg-${var.stage}-${var.servicename}-alb"
  vpc_id = var.vpc_id  # 보안 그룹이 속할 VPC ID

  # HTTPS(443) 허용 (외부 접근 허용)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list  # 허용할 CIDR 블록 목록
    self        = true  # 자신(ALB)으로부터의 트래픽 허용
  }

  # HTTP(80) 허용 (리디렉션 목적)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({
         Name = "aws-sg-${var.stage}-${var.servicename}-alb"}), var.tags)
}

# ALB -> Target Group 통신을 위한 보안 그룹 설정
resource "aws_security_group" "sg-alb-to-tg" {
  name   = "aws-sg-${var.stage}-${var.servicename}-alb-to-tg"
  vpc_id = var.vpc_id  # 보안 그룹이 속할 VPC ID

  # ALB에서 Target Group으로 트래픽 허용
  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "TCP"
    security_groups = [aws_security_group.sg-alb.id]  # ALB에서 오는 요청 허용
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({
         Name = "aws-sg-${var.stage}-${var.servicename}-alb-to-tg"}), var.tags)
}

# Route 53을 활용한 ALB 도메인 설정
# resource "aws_route53_record" "alb-record" {
#   count  = var.domain != "" ? 1 : 0  # 도메인이 있을 경우만 생성
#   zone_id = var.hostzone_id  # 호스트 존 ID (Route 53)
#   name    = "${var.stage}-${var.servicename}.${var.domain}"  # 서브도메인 설정 (예: dev-myapp.example.com)
#   type    = "A"  # A 레코드 생성

#   alias {
#     name                   = aws_lb.alb.dns_name  # ALB DNS 이름
#     zone_id                = aws_lb.alb.zone_id  # ALB Zone ID
#     evaluate_target_health = true  # 타겟 상태 평가 활성화
#   }
# }
