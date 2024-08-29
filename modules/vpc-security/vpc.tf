# provider "aws" {

#   region = var.region
#   access_key = var.access_key
#   secret_key = var.secret_key
# }


### VPC-service
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.account_name}_Account_vpc"
  }
}
