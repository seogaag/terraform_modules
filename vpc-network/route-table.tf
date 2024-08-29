resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  # 여기 dynamic으로 하면....되나?
  route {
    cidr_block = "192.118.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  }
  route {
    cidr_block = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  }
  route {
    cidr_block = "10.3.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  }
  route {
    cidr_block = "10.4.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  }

  tags = {
    Name = "rt-pub"
  }
}

resource "aws_route_table" "rt-tgw" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
  tags = {
    Name = "rt-nat"
  }
}

resource "aws_route_table_association" "rt-pub-asso1" {
  subnet_id = aws_subnet.sub-pub.id
  route_table_id = aws_route_table.rt-pub.id
}

resource "aws_route_table_association" "rt-tgw-asso" {
  subnet_id = aws_subnet.sub-tgw.id
  route_table_id = aws_route_table.rt-tgw.id
}