resource "aws_eip" "nat_eip1" {
    domain	= "vpc"
}

resource "aws_nat_gateway" "nat_gateway_1" {
    allocation_id   = aws_eip.nat_eip1.id
    subnet_id       = aws_subnet.subnet_public_Azone.id
    depends_on      = [ aws_internet_gateway.internet_gateway ]

    tags = {
        Name = "ngw-network-a"
    }
}

