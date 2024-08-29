output "tgw_id" {
  value = aws_ec2_transit_gateway.tgw.id
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

