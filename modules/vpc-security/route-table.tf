resource "aws_route_table" "rt-firewall" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = var.cidr_block_all
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name = "RT-${var.service}-${var.account_name}-firewall"
  }
}

resource "aws_route_table" "rt-tgw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "RT-${var.service}-${var.account_name}-tgw"
  }
}

resource "aws_route_table_association" "rt-firewall-asso" {
  subnet_id = aws_subnet.sub_firewall.id
  route_table_id = aws_route_table.rt-firewall.id
}

resource "aws_route_table_association" "rt-tgw-asso1" {
  subnet_id = aws_subnet.sub_tgw.id
  route_table_id = aws_route_table.rt-tgw.id
}

resource "aws_vpc_endpoint_subnet_association" "rt-tgw-asso2" {
  vpc_endpoint_id = aws_networkfirewall_firewall.networkfirewall.firewall_status[0]["attachment"]["endpoint_id"]
  subnet_id = aws_subnet.sub_tgw.id
#   route_table_id = aws_route_table.rt-tgw.id
}