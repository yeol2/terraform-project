provider "aws" {
        region = "ap-northeast-2"
        default_tags {
                tags = {
                        Name = "student0"
                        Subject = "cloud-programming"
                        Chapter = "practice3"
                }
        }
}

# vpc 
variable "vpc_main_cidr" {
        description = "VPC main CIDR block"
        default = "10.0.0.0/23"
}

resource "aws_vpc" "my_vpc" {
        cidr_block = var.vpc_main_cidr
        instance_tenancy = "default"
        enable_dns_hostnames = true
}
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = "10.1.0.0/23"
}

# 서브넷 생성Azone
resource "aws_subnet" "pub_sub_1" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, 0)
        availability_zone = "ap-northeast-2a"
        map_public_ip_on_launch = true
}
resource "aws_subnet" "prv_sub_1" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, 1)
        availability_zone = "ap-northeast-2a"
}

# 서브넷 생성 Bzone
resource "aws_subnet" "pub_sub_2" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 1, 0)
        availability_zone = "ap-northeast-2b"
        map_public_ip_on_launch = true
}
resource "aws_subnet" "prv_sub_2" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 1, 1)
        availability_zone = "ap-northeast-2b"
}

# IGW
resource "aws_internet_gateway" "my_igw" {
        vpc_id = aws_vpc.my_vpc.id
}

# public route
resource "aws_route_table" "pub_rt" {
        vpc_id = aws_vpc.my_vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = aws_internet_gateway.my_igw.id
        }
}

# private route
resource "aws_route_table" "prv_rt1" {
        vpc_id = aws_vpc.my_vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = aws_nat_gateway.nat_gw_1.id
        }
}

resource "aws_route_table" "prv_rt2" {
        vpc_id = aws_vpc.my_vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = aws_nat_gateway.nat_gw_2.id
        }
}

# route <--> subnet
resource "aws_route_table_association" "pub_rt_asso" {
        subnet_id = aws_subnet.pub_sub_1.id
        route_table_id = aws_route_table.pub_rt.id
}
resource "aws_route_table_association" "pub_rt_asso2" {
        subnet_id = aws_subnet.pub_sub_2.id
        route_table_id = aws_route_table.pub_rt.id
}
resource "aws_route_table_association" "pub_rt1_asso" {
        subnet_id = aws_subnet.prv_sub_1.id
        route_table_id = aws_route_table.prv_rt1.id
}
resource "aws_route_table_association" "pub_rt2_asso" {
        subnet_id = aws_subnet.prv_sub_2.id
        route_table_id = aws_route_table.prv_rt2.id
}

# NAT EIP
resource "aws_eip" "nat_eip1" {
        domain = "vpc"
}
resource "aws_eip" "nat_eip2" {
        domain = "vpc"
}

# NAT G/W
resource "aws_nat_gateway" "nat_gw_1" {
        allocation_id = aws_eip.nat_eip1.id
        subnet_id = aws_subnet.pub_sub_1.id
        depends_on = [aws_internet_gateway.my_igw]
}
resource "aws_nat_gateway" "nat_gw_2" {
        allocation_id = aws_eip.nat_eip2.id
        subnet_id = aws_subnet.pub_sub_2.id
        depends_on = [aws_internet_gateway.my_igw]
}