## Gitlab Region

provider "aws" {
  alias = "network"

  region = "ap-southeast-4" # 수정
}


### VPC-service
resource "aws_vpc" "vpc-network" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "Network_Account_vpc"
  }
}

# resource "aws_subnet" "sub_pub_a" {
#   vpc_id = aws_vpc.vpc-network.id
#   cidr_block = "10.0.0.0/27"
#   availability_zone = "${var.region_1}c"
# }

resource "aws_subnet" "sub_firewall_a" {
  vpc_id = aws_vpc.vpc-network.id
  cidr_block = "10.0.0.32/27"
  availability_zone = "${var.region_1}a"
}

resource "aws_subnet" "sub_protected_a" {
  vpc_id = aws_vpc.vpc-network.id
  cidr_block = "10.0.0.64/27"
  availability_zone = "${var.region_1}a"
}

resource "aws_subnet" "sub_private_a" {
  vpc_id = aws_vpc.vpc-network.id
  cidr_block = "10.0.0.96/27"
  availability_zone = "${var.region_1}a"
}

## igw ##
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc-network.id
  tags = {
    Name = "igw-${local.service}"
  }
}

## ngw ##
resource "aws_eip" "eip1" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.eip1.id
  subnet_id = aws_subnet.sub_protected_a.id
  depends_on = [ aws_internet_gateway.my_igw ]
  tags = {
    Name = "ngw-${local.service}"
  }
}

# routing table
resource "aws_route_table" "rt-FIREWALL" {
  vpc_id = aws_vpc.vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "RT-${local.service}-FIREWALL-NETWORK"
  }
}

resource "aws_route_table" "rt-EIGW" {
  vpc_id = aws_vpc.vpc-network.id
  route {
    # egress_only_gateway_id =  # 수정 이게 엣지인가?
  }
  tags = {
    Name = "RT-${local.service}-EIGW-NETWORK"
  }
}

resource "aws_route_table" "rt-PROTECTED" {
  vpc_id = aws_vpc.vpc-network.id
  tags = {
    Name = "RT-${local.service}-PROTECTED-NETWORK"
  }
}

resource "aws_route_table" "rt-PRIVATE" {
  vpc_id = aws_vpc.vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_a.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-1.id
  }
  tags = {
    Name = "RT-${local.service}-PRIVATE-NETWORK"
  }
}

## routing table association
resource "aws_route_table_association" "rt-firewall-asso" {
  subnet_id = aws_subnet.sub_firewall_a.id
  route_table_id = aws_route_table.rt-FIREWALL.id
}

# resource "aws_route_table_association" "rt-eigw-asso" {
#   subnet_id = aws_subnet.sub_pub_a.id
#   route_table_id = aws_route_table.rt-EIGW.id
# }

resource "aws_route_table_association" "rt-protected-asso" {
  subnet_id = aws_subnet.sub_protected_a.id
  route_table_id = aws_route_table.rt-PROTECTED.id
}

resource "aws_route_table_association" "rt-private-asso" {
  subnet_id = aws_subnet.sub_private_a.id
  route_table_id = aws_route_table.rt-PRIVATE.id
}

# resource "aws_route_table_association" "rt-eigw-asso2" {
#   route_table_id = aws_route_table.rt-EIGW.id
#   gateway_id = aws_internet_gateway.my_igw.id # 엣지 연결인지 확인 필요
# }

## 엔드포인트 연결
# resource "aws_vpc_endpoint_route_table_association" "rt-eigw-asso-end" {
#   route_table_id = aws_route_table.rt-EIGW.id
#   vpc_endpoint_id = aws_vpc_endpoint.endpoint-a.id # 수정 : 대상 설정 안해도 되나...? 알아서 하나...?
# }

resource "aws_vpc_endpoint_route_table_association" "rt-protected-asso-end" {
  route_table_id = aws_route_table.rt-PROTECTED.id
  vpc_endpoint_id = aws_vpc_endpoint.endpoint-a.id
}

## SG
module "lgw-sg" {
  source = "../modules/security-group"
  
  vpc_id = aws_vpc.vpc-network.id
  service_name = local.service
  user_name = local.service
}

## LB
resource "aws_lb" "lgw-lb" {
  name = "${local.service}-lb-for-gw-lb-ep"
  internal = true
  load_balancer_type = "application"
  security_groups = [module.lgw-sg.security_group_id]
  subnets = [aws_subnet.sub_protected_a.id]
}


## Gateway LoadBalancer Endpoint # 수정
data "aws_caller_identity" "current" {}

resource "aws_vpc_endpoint_service" "endpoint_service" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  gateway_load_balancer_arns = [aws_lb.lgw-lb.arn]
}

resource "aws_vpc_endpoint" "endpoint-a" {
  service_name      = aws_vpc_endpoint_service.endpoint_service.service_name
  subnet_ids        = [aws_subnet.sub_protected_a.id, aws_subnet.sub_private_a.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.endpoint_service.service_type
  vpc_id            = aws_vpc.vpc-network.id
}


### TGW
resource "aws_ec2_transit_gateway" "tgw-1" {
  description = "network tgw"
  auto_accept_shared_attachments = "enable"
  tags = {
    Name = "${var.region_1}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-network-tgw1-attachment" {
  vpc_id = aws_vpc.vpc-network.id
  subnet_ids = [aws_subnet.sub_private_a.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw-1.id
}

# resource "aws_ec2_transit_gateway_route_table" "tgw1-rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw-1.id
#   tags = {
#     Name = "RT-TGW-NETWORK"
#   }
# }

