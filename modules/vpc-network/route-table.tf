resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = var.cidr_block_all
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  dynamic "route" {
    for_each = var.cidr_blocks
    content {
        cidr_block = route.value
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    }
  }

  tags = {
    Name = "rt-${var.account_name}-pub"
  }
}

resource "aws_route_table" "rt-tgw" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = var.cidr_block_all
    gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
  tags = {
    Name = "rt-${var.account_name}-nat"
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