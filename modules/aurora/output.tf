# # RDS 관리자 비밀번호 출력 (민감 정보)
# output "rds-random-password" {
#   value     = random_password.rds-password.result
#   sensitive = true
# }
# RDS 관리자 비밀번호 출력 (민감 정보)
output "rds-random-password" {
  value     = random_password.rds-password.result
  sensitive = false
}
# RDS 클러스터 엔드포인트 출력
output "endpoint" {
  value     = aws_rds_cluster.rds-cluster.endpoint
}
# 읽기 전용(Reader) 엔드포인트 출력
output "ro_endpoint" {
  value     = aws_rds_cluster.rds-cluster.reader_endpoint
}