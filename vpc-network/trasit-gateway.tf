### TGW
resource "aws_ec2_transit_gateway" "tgw-network" {
  description = "network tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.region_network}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-network-tgw-attachment" {
  vpc_id = aws_vpc.vpc-network.id
  subnet_ids = [aws_subnet.sub-tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
}


### TGW Peering Attachment
resource "aws_ec2_transit_gateway_peering_attachment" "tgw-network-peering" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw-network.id
  peer_region = var.region_security
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw-security.id
}

data "aws_ec2_transit_gateway_attachments" "filtered" {
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tgw-main.id,
            aws_ec2_transit_gateway.tgw-stage.id,
            aws_ec2_transit_gateway.tgw-dev.id
            ] # 여기에 여러개 넣어야하는지... 각각 바꿔줘야 하는지 ?~?
  }

  filter {
    name   = "resource-type"
    values = ["peering"]
  }
}

data "aws_ec2_transit_gateway_attachment" "unit" {
  count                         = length(data.aws_ec2_transit_gateway_attachments.filtered.ids)
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_attachments.filtered.ids[count.index]
}

# ## TGW Route Table - propagation
# resource "aws_ec2_transit_gateway_route_table_propagation" "name" {
  
# }
