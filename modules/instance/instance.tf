resource "aws_instance" "ec2" {
  ami = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.sg_ec2.id]

  key_name = var.keypair_name

  root_block_device {
    volume_size = var.ec2_volume_size
  }

  user_data = var.user_data

  tags = {
    Name = var.ec2_name
  }
}

## Security Group
resource "aws_security_group" "sg_ec2" {
  vpc_id = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.sg_port_list
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = var.sg_cidr_blocks
    }

  }
}