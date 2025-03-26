# EC2 인스턴스 ID 출력
output "instance_id" {
  value = aws_instance.ec2.id
  # 생성된 EC2 인스턴스의 고유 ID 출력 (예: "i-0abcdef1234567890")
  # 이 값을 사용하여 다른 Terraform 모듈에서 참조 가능
}

# EC2 Security Group ID 출력
output "sg-ec2-comm_id" {
  value = aws_security_group.sg-ec2-comm.id
  # 생성된 보안 그룹의 ID 출력 (예: "sg-0123456789abcdef0")
  # 다른 모듈이나 서비스에서 보안 그룹을 참조할 때 사용 가능
}

# EC2 인스턴스가 배치된 가용 영역(AZ) 출력
output "instance_az" {
  value = aws_instance.ec2.availability_zone
  # 인스턴스가 배치된 AWS의 가용 영역(AZ) 출력
  # 여러 가용 영역에서 배포할 때 유용
}

