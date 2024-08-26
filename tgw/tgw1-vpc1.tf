## Gitlab Region

provider "aws" {
  region = "ap-southeast-4" # 수정
}

### TGW
resource "aws_ec2_transit_gateway" "tgw-1" {
  description = "network tgw"
}

### VPC-service
resource "aws_vpc" "vpc-a" {
  cidr_block = "10.0.0.0/24"
  tags = {
    "Name" = "Network_Account_vpc"
  }
}

resource "aws_subnet" "sub_pub_a" {
  vpc_id = aws_vpc.vpc-a.id
  cidr_block = "10.0.0.0/27"
  availability_zone = "${var.region_1}a"
}

resource "aws_subnet" "sub_nat_a" {
  vpc_id = aws_vpc.vpc-a.id
  cidr_block = "10.0.0.32/27"
  availability_zone = "${var.region_1}a"
}

## igw ##
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc-a.id
  tags = {
    Name = "igw-${var.service}"
  }
}

## ngw ##
resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.sub_pub_a.id
  depends_on = [ aws_internet_gateway.my_igw ]
  tags = {
    Name = "ngw-${var.service}"
  }
}

# routing table
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "RT-${var.service}-EIGW-NETWORK"
  }
}

resource "aws_route_table" "rt_nat" {
  vpc_id = aws_vpc.my_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_a.id
  }
  tags = {
    Name = "RT-${var.service}-NAT-NETWORK"
  }
}

## routing table association
resource "aws_route_table_association" "rt_pub_asso" {
  subnet_id = aws_subnet.sub_pub_a.id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rt_nat_asso" {
  subnet_id = aws_subnet.sub_nat_a
  route_table_id = aws_route_table.rt_nat.id
}

## 엔드포인트 연결





### VPC-Firewall
resource "aws_vpc" "vpc-b" {
  cidr_block = "100.64.0.0/26"
  tags = {
    "Name" = "Inspection_VPC_A"
  }
}

resource "aws_subnet" "sub_Firewall_A" {
  vpc_id = aws_vpc.vpc-b.id
  cidr_block = "100.64.0.16/28"
  availability_zone = "${var.region_1}a"
}

resource "aws_subnet" "sub_Firewall_A_TGW" {
  vpc_id = aws.vpc-b.id
  cidr_block = "100.64.0.0/28"
  availability_zone = "${var.region_1}a"
}

