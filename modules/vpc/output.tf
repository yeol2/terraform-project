# 데이터베이스 서브넷 출력
output "db-az1" {
  value = aws_subnet.db-az1  # AZ1에 위치한 DB 서브넷 정보 출력
}

output "db-az2" {
  value = aws_subnet.db-az2  # AZ2에 위치한 DB 서브넷 정보 출력
}

# VPC 정보 출력
output "network-vpc" {
  value = aws_vpc.aws-vpc  # 생성된 VPC 전체 정보 출력
}

# 퍼블릭 서브넷 출력
output "public-az1" {
  value = aws_subnet.public-az1  # AZ1 퍼블릭 서브넷 정보 출력
}

output "public-az2" {
  value = aws_subnet.public-az2  # AZ2 퍼블릭 서브넷 정보 출력
}

# 서비스 서브넷 출력
output "service-az1" {
  value = aws_subnet.service-az1  # AZ1 서비스 서브넷 정보 출력
}

output "service-az2" {
  value = aws_subnet.service-az2  # AZ2 서비스 서브넷 정보 출력
}

# VPC ID 출력
output "vpc_id" {
  value = aws_vpc.aws-vpc.id  # VPC의 ID 출력
}

# VPC의 CIDR 블록 출력
output "vpc_cidr" {
  value = aws_vpc.aws-vpc.cidr_block  # VPC의 CIDR 블록 출력
}

# NAT
output "nat_ip_az1" {
  value = aws_eip.nat-eip-az1.public_ip
}
output "nat_ip_az2" {
  value = aws_eip.nat-eip-az2.public_ip
}

output "nat_id_az1" {
  value = aws_nat_gateway.vpc-nat-az1.id
}

output "nat_id_az2" {
  value = aws_nat_gateway.vpc-nat-az2.id
}

# DB
output "db_rt_az1_id" {
  value = aws_route_table.aws-rt-db.id
}