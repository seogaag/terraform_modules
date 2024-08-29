resource "aws_subnet" "sub-pub" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 2,0)
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-${var.account_name}-pub-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "sub-tgw" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 2,1)
  availability_zone = "${var.region}a"
  tags = {
    Name = "subnet-${var.account_name}-nat-a"
  }
}