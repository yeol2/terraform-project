provider "aws" {
        region = "ap-northeast-2"
}

# vpc 생성
resource "aws_vpc" "my_vpc" {
        cidr_block = var.vpc_main_cidr
        instance_tenancy = "default"
        enable_dns_hostnames = true
        tags = {
                Name = "${var.project_name}-vpc"
        }
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
        tags = {
                Name = "${var.project_name}-subnet-public-a"
        }
}
resource "aws_subnet" "prv_sub_1" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, 1)
        availability_zone = "ap-northeast-2a"
        tags = {
                Name = "${var.project_name}-subnet-private-a"
        }
}

# 서브넷 생성 Bzone
resource "aws_subnet" "pub_sub_2" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 1, 0)
        availability_zone = "ap-northeast-2b"
        map_public_ip_on_launch = true
        tags = {
                Name = "${var.project_name}-subnet-public-b"
        }
}
resource "aws_subnet" "prv_sub_2" {
        vpc_id = aws_vpc.my_vpc.id
        cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 1, 1)
        availability_zone = "ap-northeast-2b"
        tags = {
                Name = "${var.project_name}-subnet-private-b"
        }

}

# IGW
resource "aws_internet_gateway" "my_igw" {
        vpc_id = aws_vpc.my_vpc.id
        tags = {
                Name = "${var.project_name}-igw"
        }
}

# public route
resource "aws_route_table" "pub_rt" {
        vpc_id = aws_vpc.my_vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = aws_internet_gateway.my_igw.id
        }
        tags = {
                Name = "${var.project_name}-rt-public"
        }
}

# private route
resource "aws_route_table" "prv_rt1" {
        vpc_id = aws_vpc.my_vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = aws_nat_gateway.nat_gw_1.id
        }
        tags = {
                Name = "${var.project_name}-rt-private-a"
        }
}

resource "aws_route_table" "prv_rt2" {
        vpc_id = aws_vpc.my_vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                nat_gateway_id = aws_nat_gateway.nat_gw_2.id
        }
        tags = {
                Name = "${var.project_name}-rt-private-b"
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
        tags = {
                Name = "${var.project_name}-eip-nat-a"
        }
}
resource "aws_eip" "nat_eip2" {
        domain = "vpc"
        tags = {
                Name = "${var.project_name}-eip-nat-b"
        }
}

# NAT G/W
resource "aws_nat_gateway" "nat_gw_1" {
        allocation_id = aws_eip.nat_eip1.id
        subnet_id = aws_subnet.pub_sub_1.id
        depends_on = [aws_internet_gateway.my_igw]
        tags = {
                Name = "${var.project_name}-nat-a"
        }
}
resource "aws_nat_gateway" "nat_gw_2" {
        allocation_id = aws_eip.nat_eip2.id
        subnet_id = aws_subnet.pub_sub_2.id
        depends_on = [aws_internet_gateway.my_igw]
        tags = {
                Name = "${var.project_name}-nat-b"
        }
}

# 인프라 생성용 terraform 프로젝트 생성
# terraform {
#         required_version = ">= 1.0.0, < 2.0.0"

#         backend "s3" {
#                 bucket = "250320-rowan-practice4"
#                 key = "vpc/terraform.tfstate"
#                 region = "ap-northeast-2"
#                 encrypt = true
#                 # use_lockfile = true
#         }
# }