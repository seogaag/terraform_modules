## LoadBalancer - Application
resource "aws_lb" "alb-internal_facing" {
  name = var.alb_name
  internal = false
  load_balancer_type = "application"
  
  subnets = [aws_subnet.sub_pub_a_id, aws_subnet.sub_pub_c_id]
  security_groups = [aws_security_group.alb_sg.id]
}

## ALB TargetGroup
resource "aws_lb_target_group" "target_group" {
  name = "tg-${var.alb_name}"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200, 302, 301"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "target-group-attachment" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = var.instance_ids[count.index]
  port             = var.port
  
  availability_zone = var.availability_zone
  
  depends_on =[aws_lb_target_group.target-group]
}


## ALB listener 80->443->SSL
resource "aws_lb_listener" "lb_listener_443" {
  load_balancer_arn = aws_lb.alb-internal_facing.arn
  port = "443"
  protocol = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_alb.arn
  }

  depends_on = [ aws_lb_target_group.target_group ]
}
resource "aws_lb_listener" "lb_listener_80" {
  load_balancer_arn = aws_lb.alb-internal_facing.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


## ALB listener rule
resource "aws_lb_listener_rule" "alb_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group
  }
}

## ALB Security Group
resource "aws_security_group" "sg-alb" {
  name = "aws-sg-${var.alb_name}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
    description = ""
    self        = true
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
    description = ""
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg-alb-to-tg" {
  name = "aws-sg-${var.alb_name}-to-tg"

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "TCP"
    security_groups = [aws_security_group.sg-alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "alb_record" {
  count = var.domain != "" ? 1:0
  zone_id = var.hostzone_id
  name = "${servicename}.${var.domain}"
  type = "A"
  alias {
    name = aws_lb.alb-internal_facing.dns_name
    zone_id = aws_lb.alb-internal_facing.zone_id
    evaluate_target_health = true
  }
}