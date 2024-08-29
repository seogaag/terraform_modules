resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc-security.id
  route {
    cidr_block = var.cidr_block_all
    transit_gateway_id = aws_ec2_transit_gateway.tgw-2.id
  }
  
  tags = {
    Name = "RT-${var.service}-security"
  }
}

resource "aws_route_table_association" "security_asso1" {
  subnet_id = aws_subnet.sub_sh_prv.id
  route_table_id = aws_route_table.rt-security-prv.id
}

resource "aws_route_table_association" "security_asso2" {
  subnet_id = aws_subnet.sub_sh_tgw.id
  route_table_id = aws_route_table.rt-security-prv.id
}
