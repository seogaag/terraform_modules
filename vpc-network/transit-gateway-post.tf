## TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw-rt-post" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  tags = {
    Name = "RT-TGW-NETWORK-PostInspection"
  }
}

## TGW Route Table Asso
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-post-asso" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway.tgw-network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-post.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-post-asso1" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_attachments.filtered.id[0]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-post.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-post-asso2" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_attachments.filtered.id[1]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-post.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-post-asso3" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_attachments.filtered.id[2]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-post.id
}