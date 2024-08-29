
resource "aws_subnet" "sub_firewall" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,2,0)
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "sub_tgw" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,2,1)
  availability_zone = "${var.region}a"
}
