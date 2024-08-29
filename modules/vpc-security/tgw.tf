### TGW
resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.account_name} tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.account_name}-tgw"
  }
}

## VPC - TGW 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-tgw-attachment" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.sub_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}
