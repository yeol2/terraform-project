# Target Group에 연결된 ALB 보안 그룹 ID 출력
output "sg_alb_to_tg_id" {
  value = aws_security_group.sg-alb-to-tg.id
  # ALB에서 Target Group으로 트래픽을 전달하는 보안 그룹 ID
  # 다른 Terraform 모듈에서 참조할 수 있도록 출력
  # 예제 값: "sg-0a1b2c3d4e5f6g7h"
}

# ALB의 DNS 이름 출력
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
  # 생성된 ALB의 DNS 이름 출력
  # ALB를 사용할 때 도메인 또는 엔드포인트로 활용 가능
  # 예제 값: "my-alb-1234567890.us-east-1.elb.amazonaws.com"
}

# ALB의 Route 53 호스팅 존 ID 출력
output "alb_zone_id" {
  value = aws_lb.alb.zone_id
  # ALB의 Zone ID를 출력하여 Route 53과 연동할 때 사용 가능
  # 예제 값: "Z1D633PJN98FT9"
}

# ALB Target Group ARN 출력 (modules/alb/output.tf)
output "alb_target_group_arn" {
  value       = aws_lb_target_group.target-group.arn
  description = "ALB에서 생성된 Target Group ARN"
}
output "alb_sg_id" {
  value = aws_security_group.sg-alb.id
}


