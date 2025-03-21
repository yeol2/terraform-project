output "alb_dns_name" {
    value = aws_lb.webserver_alb.dns_name
    description = "The domain name of the load balancer"
}
output "deployed_version" {
  value       = "v1.0.0"
  description = "현재 배포된 버전"
}