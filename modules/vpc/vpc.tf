# vpc/ subnet
# public subnet az1, 2
# service subnet az1, 2
# db subnet az1, 2
# igw
# nat
# route table pub,pri
# route table association

resource "aws_vpc" "aws-vpc" {
  cidr_block           = var.vpc_ip_range
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(tomap({
         Name = "aws-vpc-${var.stage}-${var.servicename}"}), 
        var.tags)
}

# Public Subnet AZ1
resource "aws_subnet" "public-az1" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = var.subnet_public_az1
  map_public_ip_on_launch = false
  availability_zone       = element(var.az, 0)
  tags = merge(tomap({
         Name = "aws-subnet-${var.stage}-${var.servicename}-pub-az1"}), 
        var.tags)
  depends_on = [aws_vpc.aws-vpc]
}

# Public Subnet AZ2
resource "aws_subnet" "public-az2" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = var.subnet_public_az2
  map_public_ip_on_launch = false
  availability_zone       = element(var.az, 1)
  tags = merge(tomap({
         Name = "aws-subnet-${var.stage}-${var.servicename}-pub-az2"}), 
        var.tags)
  depends_on = [aws_vpc.aws-vpc]
}

# Service Subnet AZ1
resource "aws_subnet" "service-az1" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = var.subnet_service_az1
  map_public_ip_on_launch = false
  availability_zone       = element(var.az, 0)
  tags = merge(tomap({
         Name = "aws-subnet-${var.stage}-${var.servicename}-svc-az1"}), 
        var.tags)
  depends_on = [aws_vpc.aws-vpc]
}

# Service Subnet AZ2
resource "aws_subnet" "service-az2" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = var.subnet_service_az2
  map_public_ip_on_launch = false
  availability_zone       = element(var.az, 1)
  tags = merge(tomap({
         Name = "aws-subnet-${var.stage}-${var.servicename}-svc-az2"}), 
        var.tags)
  depends_on = [aws_vpc.aws-vpc]
}

# DB Subnet AZ1
resource "aws_subnet" "db-az1" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = var.subnet_db_az1
  map_public_ip_on_launch = false
  availability_zone       = element(var.az, 0)
  tags = merge(tomap({
         Name = "aws-subnet-${var.stage}-${var.servicename}-db-az1"}), 
        var.tags)
  depends_on = [aws_vpc.aws-vpc]
}

# DB Subnet AZ2
resource "aws_subnet" "db-az2" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = var.subnet_db_az2
  map_public_ip_on_launch = false
  availability_zone       = element(var.az, 1)
  tags = merge(tomap({
         Name = "aws-subnet-${var.stage}-${var.servicename}-db-az2"}), 
        var.tags)
  depends_on = [aws_vpc.aws-vpc]
}

# # RDS Subnet Group 
# # Fowler - Merge이후 주석 삭제
# resource "aws_db_subnet_group" "db-subnet-group-gitlab" {
#   name                    = "aws-db-subnet-group-gitlab"
#   subnet_ids              = [aws_subnet.db-az1.id, aws_subnet.db-az2.id]
#   tags                    = merge(tomap({
#                             Name = "aws-db-subnet-group-gitlab"}), 
#                             var.tags)
# }

# # redis Subnet Group 
# # Fowler - Merge이후 주석 삭제
# resource "aws_elasticache_subnet_group" "redis-subnet-group-gitlab" {
#   name                    = "aws-redis-subnet-group-gitlab"
#   subnet_ids              = [aws_subnet.db-az1.id, aws_subnet.db-az2.id]
#   tags                    = merge(tomap({
#                             Name = "aws-redis-subnet-group-gitlab"}), 
#                             var.tags)
# }

# Internet Gateway
resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = merge(tomap({
         Name = "aws-igw-${var.stage}-${var.servicename}"}), 
        var.tags)
}

# EIP for NAT-A
resource "aws_eip" "nat-eip-az1" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.vpc-igw]
  tags = merge(tomap({
         Name = "aws-eip-A-${var.stage}-${var.servicename}-nat"}), 
        var.tags)
}

# NAT Gateway for public-A 
resource "aws_nat_gateway" "vpc-nat-az1" {
  allocation_id = aws_eip.nat-eip-az1.id
  subnet_id     = aws_subnet.public-az1.id
  depends_on    = [aws_internet_gateway.vpc-igw, aws_eip.nat-eip-az1]
  tags = merge(tomap({
         Name = "aws-nat-A-${var.stage}-${var.servicename}"}), 
        var.tags)    
}

# EIP for NAT-C
resource "aws_eip" "nat-eip-az2" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.vpc-igw]
  tags = merge(tomap({
         Name = "aws-eip-C-${var.stage}-${var.servicename}-nat"}), 
        var.tags)
}

# NAT Gateway for public-C
resource "aws_nat_gateway" "vpc-nat-az2" {
  allocation_id = aws_eip.nat-eip-az2.id
  subnet_id     = aws_subnet.public-az2.id
  depends_on    = [aws_internet_gateway.vpc-igw, aws_eip.nat-eip-az2]
  tags = merge(tomap({
         Name = "aws-nat-C-${var.stage}-${var.servicename}"}), 
        var.tags)
}


# Route Table - public
resource "aws_route_table" "aws-rt-pub" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = merge(tomap({
         Name = "aws-rt-${var.stage}-${var.servicename}-pub"}), 
        var.tags)
}

# Public Route to IGW
resource "aws_route" "route-to-igw" {
  route_table_id         = aws_route_table.aws-rt-pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc-igw.id
  lifecycle {
    create_before_destroy = true
  }
}

# Route Table - private A
resource "aws_route_table" "aws-rt-pri-az1" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = merge(tomap({
         Name = "aws-rt-${var.stage}-${var.servicename}-pri-az1"}), 
        var.tags)
}

# Route Table - private C
resource "aws_route_table" "aws-rt-pri-az2" {
	vpc_id = aws_vpc.aws-vpc.id
	# 태그
	tags = merge(tomap({
         Name = "aws-rt-${var.stage}-${var.servicename}-pri-az2"}), 
        var.tags)
}

# Route Table -DB
resource "aws_route_table" "aws-rt-db" {
	vpc_id = aws_vpc.aws-vpc.id
	# 태그
	tags = merge(tomap({
    Name = "aws-rt-${var.stage}-${var.servicename}-db"
  }), var.tags)
}

# Private Route to NAT
resource "aws_route" "route-to-nat-az1" {
	route_table_id = aws_route_table.aws-rt-pri-az1.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.vpc-nat-az1.id
}	

resource "aws_route" "route-to-nat-az2" {
	route_table_id = aws_route_table.aws-rt-pri-az2.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.vpc-nat-az2.id
}	

# Route Table Associations
# Public Subnet → Public Route Table
resource "aws_route_table_association" "public-az1" {
  subnet_id      = aws_subnet.public-az1.id
  route_table_id = aws_route_table.aws-rt-pub.id
}

resource "aws_route_table_association" "public-az2" {
  subnet_id      = aws_subnet.public-az2.id
  route_table_id = aws_route_table.aws-rt-pub.id
}

# Service Subnet → Private Route Table
resource "aws_route_table_association" "service-az1" {
  subnet_id      = aws_subnet.service-az1.id
  route_table_id = aws_route_table.aws-rt-pri-az1.id
}

resource "aws_route_table_association" "service-az2" {
  subnet_id      = aws_subnet.service-az2.id
  route_table_id = aws_route_table.aws-rt-pri-az2.id
}


# 라우트 테이블 연결 설정 (DB Subnet -> Private Route Table)
resource "aws_route_table_association" "db-az1" {
	subnet_id = aws_subnet.db-az1.id
	route_table_id = aws_route_table.aws-rt-db.id
}
resource "aws_route_table_association" "db-az2" {
	subnet_id = aws_subnet.db-az2.id
	route_table_id = aws_route_table.aws-rt-db.id
}