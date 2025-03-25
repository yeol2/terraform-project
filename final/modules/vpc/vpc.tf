# vpc/ subnet
# public subnet az1, 2
# service subnet az1, 2 
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

# Internet Gateway
resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = merge(tomap({
         Name = "aws-igw-${var.stage}-${var.servicename}"}), 
        var.tags)
}

# EIP for NAT
resource "aws_eip" "nat-eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.vpc-igw]
  tags = merge(tomap({
         Name = "aws-eip-${var.stage}-${var.servicename}-nat"}), 
        var.tags)
}

# NAT Gateway
resource "aws_nat_gateway" "vpc-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-az1.id
  depends_on    = [aws_internet_gateway.vpc-igw, aws_eip.nat-eip]
  tags = merge(tomap({
         Name = "aws-nat-${var.stage}-${var.servicename}"}), 
        var.tags)    
}

# Route Table - Public
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

# Route Table - Private
resource "aws_route_table" "aws-rt-pri" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = merge(tomap({
         Name = "aws-rt-${var.stage}-${var.servicename}-pri"}), 
        var.tags)
}

# Private Route to NAT
resource "aws_route" "route-to-nat" {
  route_table_id         = aws_route_table.aws-rt-pri.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-nat.id
}

# Route Table Associations
resource "aws_route_table_association" "public-az1" {
 subnet_id      = aws_subnet.public-az1.id
 route_table_id = aws_route_table.aws-rt-pub.id
}
resource "aws_route_table_association" "public-az2" {
 subnet_id      = aws_subnet.public-az2.id
 route_table_id = aws_route_table.aws-rt-pub.id
}
resource "aws_route_table_association" "service-az1" {
 subnet_id      = aws_subnet.service-az1.id
 route_table_id = aws_route_table.aws-rt-pri.id
}
resource "aws_route_table_association" "service-az2" {
 subnet_id      = aws_subnet.service-az2.id
 route_table_id = aws_route_table.aws-rt-pri.id
}
resource "aws_route_table_association" "db-az1" {
 subnet_id      = aws_subnet.db-az1.id
 route_table_id = aws_route_table.aws-rt-pri.id
}
resource "aws_route_table_association" "db-az2" {
 subnet_id      = aws_subnet.db-az2.id
 route_table_id = aws_route_table.aws-rt-pri.id
}