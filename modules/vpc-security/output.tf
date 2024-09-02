output "vpc_cidr_block" {
  value = aws_vpc.my_vpc.cidr_block
}

output "firewall_endpoint_ids" {
  value = aws_networkfirewall_firewall.networkfirewall.firewall_status[0]["attachment"]["endpoint_id"]
}


output "sub_tgw" {
  value = aws_subnet.sub_tgw
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}