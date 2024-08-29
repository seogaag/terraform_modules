resource "aws_subnet" "sub-pub" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/27"
  availability_zone = "${var.region_network}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-network-pub-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "sub-tgw" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.32/27"
  availability_zone = "${var.region_network}a"
  tags = {
    Name = "subnet-network-nat-a"
  }
}