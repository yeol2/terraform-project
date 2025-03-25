output "vpc_id" {
  value       = aws_vpc.aws-vpc.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = [aws_subnet.public-az1.id, aws_subnet.public-az2.id]
  description = "IDs of public subnets"
}

output "service_subnet_ids" {
  value       = [aws_subnet.service-az1.id, aws_subnet.service-az2.id]
  description = "IDs of service subnets"
}

output "db_subnet_ids" {
  value       = [aws_subnet.db-az1.id, aws_subnet.db-az2.id]
  description = "IDs of database subnets"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.vpc-nat.id
  description = "NAT Gateway ID"
}

output "igw_id" {
  value       = aws_internet_gateway.vpc-igw.id
  description = "Internet Gateway ID"
}
