resource "aws_security_group" "security_group" {
    name        = "${var.service_name}-sg-${var.user_name}"
    vpc_id      = var.vpc_id
    description = var.description

    dynamic "ingress" {
        for_each = var.ingress_rule
        content {
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }

    dynamic "egress" {
        for_each = var.egress_rule
        content {
            from_port   = egress.value.from_port
            to_port     = egress.value.to_port
            protocol    = egress.value.protocol
            cidr_blocks = egress.value.cidr_blocks
        }
    }
}
