
resource "aws_subnet" "sub_prv" {
  vpc_id = aws_vpc.vpc-security.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,2,0)
  availability_zone = "${var.region_security}a"
}

resource "aws_subnet" "sub_tgw" {
  vpc_id = aws_vpc.vpc-security.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,2,1)
  availability_zone = "${var.region_security}a"
}
