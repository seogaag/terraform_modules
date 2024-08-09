output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.my_vpc.cidr_block
}

## subnet id
output "sub_pub_a_id" {
  value = aws_subnet.sub_pub_a.id
}

output "sub_pub_c_id" {
  value = aws_subnet.sub_pub_c.id
}

output "sub_prv_nat_a_id" {
  value = aws_subnet.sub_prv_nat_a.id
}

output "sub_prv_nat_c_id" {
  value = aws_subnet.sub_prv_nat_c.id
}

output "sub_prv_a_id" {
  value = aws_subnet.sub_prv_a
}

output "sub_prv_c_id" {
  value = aws_subnet.sub_prv_c
}