### TGW
resource "aws_ec2_transit_gateway" "tgw-security" {
  description = "security tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "security-tgw"
  }
}

## VPC - TGW 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-security-tgw-attachment" {
  vpc_id = aws_vpc.vpc-security.id
  subnet_ids = [aws_subnet.sub_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw-security.id
}
