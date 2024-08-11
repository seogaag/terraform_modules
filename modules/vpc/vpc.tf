# provider "aws" {
#   region = var.region
#   default_tags {
#     tags = {
#       Name = "VPC-001109"
#     }
#   }  
# }

## vpc ##
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true # 인스턴스간 DNS 이름으로 접근 가능
  tags = {
    Name = var.vpc_name
  }
}

## subnet ##
# public subnet - a, c
resource "aws_subnet" "sub_pub_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3,0)
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[0]
    "kubernetes.io/role/elb" = "1"
  }
}
resource "aws_subnet" "sub_pub_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3,1)
  availability_zone = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[1]
    "kubernetes.io/role/elb" = "1"
  }
}

# private subnet nat - a, c
resource "aws_subnet" "sub_prv_nat_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3,2)
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[2]
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_subnet" "sub_prv_nat_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3,3)
  availability_zone = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[3]
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# private subnet - a, c
resource "aws_subnet" "sub_prv_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3,4)
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[4]
  }
}
resource "aws_subnet" "sub_prv_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3,5)
  availability_zone = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[5]
  }
}

## igw ##
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = var.igw_name
  }
}

## elastic ip ##
resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}
resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

## ngw - a, c ##
resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id = aws_subnet.sub_pub_a.id
  depends_on = [ aws_internet_gateway.my_igw ]
  tags = {
    Name = var.ngw_names[0]
  }
}
resource "aws_nat_gateway" "ngw_c" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id = aws_subnet.sub_pub_c.id
  depends_on = [ aws_internet_gateway.my_igw ]
  tags = {
    Name = var.ngw_names[1]
  }
}

## routing taable ##
# public routing table
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "RT-001109-pub"
  }
}

# private nat routing table
resource "aws_route_table" "rt_prv_nat_a" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_a.id
  }
  tags = {
    Name = "RT-001109-prv-nat-a"
  }
}
resource "aws_route_table" "rt_prv_nat_c" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_c.id
  }
  tags = {
    Name = "RT-001109-prv-nat-c"
  }
}

# private routing table
resource "aws_route_table" "rt_prv" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "RT-001109-prv"
  }
}

## routing table association
# rt_pub asso
resource "aws_route_table_association" "rt_pub_asso1" {
  subnet_id = aws_subnet.sub_pub_a.id
  route_table_id = aws_route_table.rt_pub.id
}
resource "aws_route_table_association" "rt_pub_asso2" {
  subnet_id = aws_subnet.sub_pub_c.id
  route_table_id = aws_route_table.rt_pub.id
}

# rt_prv_nat_a asso
resource "aws_route_table_association" "rt_prv_nat_a_asso" {
  subnet_id = aws_subnet.sub_prv_nat_a.id
  route_table_id = aws_route_table.rt_prv_nat_a.id
}
# rt_prv_nat_c asso
resource "aws_route_table_association" "rt_prv_nat_c_asso" {
  subnet_id = aws_subnet.sub_prv_nat_c.id
  route_table_id = aws_route_table.rt_prv_nat_c.id
}

# rt_prv asso
resource "aws_route_table_association" "rt_prv_asso1" {
  subnet_id = aws_subnet.sub_prv_a.id
  route_table_id = aws_route_table.rt_prv.id
}
resource "aws_route_table_association" "rt_prv_asso2" {
  subnet_id = aws_subnet.sub_prv_c.id
  route_table_id = aws_route_table.rt_prv.id
}

