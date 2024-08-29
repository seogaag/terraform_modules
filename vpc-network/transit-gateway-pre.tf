## TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw-rt-pre" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  tags = {
    Name = "RT-TGW-NETWORK-PreInspection"
  }
}



## TGW Route Table Asso
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-pre-asso" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc-network-tgw-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-pre.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-pre-asso1" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw-network-peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-pre.id

}