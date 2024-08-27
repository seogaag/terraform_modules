## Peering 1-2 - TGW 연결
resource "aws_ec2_transit_gateway_peering_attachment" "peering-tgw-1-2" {
  peer_account_id = aws_ec2_transit_gateway.tgw-1.owner_id
  peer_region = var.region_1
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw-1.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw-2.id
}

## Peering Accept - 1계정에서
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peering-tgw-1-2-accept" {
#   provider = aws.network
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.peering-tgw-1-2.id
}

## Peering 1-3 - TGW 연결
resource "aws_ec2_transit_gateway_peering_attachment" "peering-tgw-1-3" {
  peer_account_id = aws_ec2_transit_gateway.tgw-1.owner_id
  peer_region = var.region_1
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw-1.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw-3.id
}

## Peering Accept - 1계정에서
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peering-tgw-1-3-accept" {
#   provider = aws.network
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.peering-tgw-1-3.id
}
