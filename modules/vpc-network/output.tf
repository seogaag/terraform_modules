output "tgw" {
  value = aws_ec2_transit_gateway.tgw
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

