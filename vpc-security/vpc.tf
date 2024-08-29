### VPC-service
resource "aws_vpc" "vpc-security" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "security_Account_vpc"
  }
}
