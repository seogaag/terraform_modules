### TGW
resource "aws_ec2_transit_gateway" "tgw" {
  description = "network tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.region}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-tgw-attachment" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.sub-tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

## TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw-rt-pre" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "RT-tgw-PreInspection"
  }
}


## TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw-rt-post" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "RT-tgw-PostInspection"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-post-asso" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc-tgw-attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-post.id
}
