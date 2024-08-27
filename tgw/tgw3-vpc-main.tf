provider "aws" {
  alias = "main"

  region = "us-east-1"
}


### VPC-service
resource "aws_vpc" "vpc-main" {
  cidr_block = "10.2.0.0/16"
  tags = {
    "Name" = "main_Account_vpc"
  }
}

resource "aws_subnet" "sub_main_prv_a" {
  vpc_id = aws_vpc.vpc-main.id
  cidr_block = "10.2.0.0/27"
  availability_zone = "${var.region_2}a"
}

resource "aws_subnet" "sub_main_prv_c" {
  vpc_id = aws_vpc.vpc-main.id
  cidr_block = "10.2.0.32/27"
  availability_zone = "${var.region_2}c"
}

resource "aws_subnet" "sub_main_db_a" {
  vpc_id = aws_vpc.vpc-main.id
  cidr_block = "10.2.0.64/27"
  availability_zone = "${var.region_2}a"
}

resource "aws_subnet" "sub_main_db_c" {
  vpc_id = aws_vpc.vpc-main.id
  cidr_block = "10.2.0.96/27"
  availability_zone = "${var.region_2}c"
}

resource "aws_subnet" "sub_main_tgw_a" {
  vpc_id = aws_vpc.vpc-main.id
  cidr_block = "10.2.0.128/27"
  availability_zone = "${var.region_2}a"
}

resource "aws_subnet" "sub_main_tgw_c" {
  vpc_id = aws_vpc.vpc-main.id
  cidr_block = "10.2.0.160/27"
  availability_zone = "${var.region_2}c"
}



resource "aws_route_table" "rt-main-prv" {
  vpc_id = aws_vpc.vpc-main.id
  route {
    cidr_block = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-3.id
  }
  tags = {
    Name = "RT-${local.service}-main"
  }
}

resource "aws_route_table_association" "main_asso1" {
  subnet_id = aws_subnet.sub_main_prv_a.id
  route_table_id = aws_route_table.rt-main-prv.id
}

resource "aws_route_table_association" "main_asso2" {
  subnet_id = aws_subnet.sub_main_prv_c.id
  route_table_id = aws_route_table.rt-main-prv.id
}

resource "aws_route_table_association" "main_asso3" {
  subnet_id = aws_subnet.sub_main_db_a.id
  route_table_id = aws_route_table.rt-main-prv.id
}

resource "aws_route_table_association" "main_asso4" {
  subnet_id = aws_subnet.sub_main_db_c.id
  route_table_id = aws_route_table.rt-main-prv.id
}

resource "aws_route_table_association" "main_asso5" {
  subnet_id = aws_subnet.sub_main_tgw_a.id
  route_table_id = aws_route_table.rt-main-prv.id
}

resource "aws_route_table_association" "main_asso6" {
  subnet_id = aws_subnet.sub_main_tgw_c.id
  route_table_id = aws_route_table.rt-main-prv.id
}

### TGW
resource "aws_ec2_transit_gateway" "tgw-3" {
  description = "main tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.region_3}-tgw"
  }
}

## VPC - TGW 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-main-tgw3-attachment1" {
  vpc_id = aws_vpc.vpc-main.id
  subnet_ids = [aws_subnet.sub_main_tgw_a.id,
                aws_subnet.sub_main_tgw_c.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw-3.id
}