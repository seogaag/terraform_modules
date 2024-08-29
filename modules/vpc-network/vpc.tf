# provider "aws" {
#   region = var.region
#   access_key = var.access_key
#   secret_key = var.secret_key
# }

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "vpc-${var.account_name}"
  }
}