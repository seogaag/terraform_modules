provider "aws" {
  alias = "shared"

  region = "ap-south-1" # 수정
}

### VPC-service
resource "aws_vpc" "vpc-shared" {
  cidr_block = "10.1.0.0/16"
  tags = {
    "Name" = "Shared_Account_vpc"
  }
}

resource "aws_subnet" "sub_sh_prv" {
  vpc_id = aws_vpc.vpc-shared.id
  cidr_block = "10.1.0.0/27"
  availability_zone = "${var.region_2}a"
}

resource "aws_subnet" "sub_sh_tgw" {
  vpc_id = aws_vpc.vpc-shared.id
  cidr_block = "10.1.0.32/27"
  availability_zone = "${var.region_2}a"
}


resource "aws_route_table" "rt-shared-prv" {
  vpc_id = aws_vpc.vpc-shared.id
  route {
    cidr_block = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-2.id
  }
  
  tags = {
    Name = "RT-${local.service}-SHARED"
  }
}

resource "aws_route_table_association" "shared_asso1" {
  subnet_id = aws_subnet.sub_sh_prv.id
  route_table_id = aws_route_table.rt-shared-prv.id
}

resource "aws_route_table_association" "shared_asso2" {
  subnet_id = aws_subnet.sub_sh_tgw.id
  route_table_id = aws_route_table.rt-shared-prv.id
}

### TGW
resource "aws_ec2_transit_gateway" "tgw-2" {
  description = "shared tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.region_2}-tgw"
  }
}

## VPC - TGW 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-shared-tgw2-attachment1" {
  vpc_id = aws_vpc.vpc-shared.id
  subnet_ids = [aws_subnet.sub_sh_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw-2.id
}

# resource "aws_ec2_transit_gateway_route_table" "tgw2-rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw-2.id
#   tags = {
#     Name = "RT-TGW-NETWORK"
#   }
# }
