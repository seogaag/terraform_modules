output "vpc_cidr_block" {
  value = aws_vpc.my_vpc.cidr_block
}

output "firewall_endpoint_ids" { # ?????어케해용
  value = aws_networkfirewall_firewall.networkfirewall.firewall_status.attachment["endpoint_id"]
}
