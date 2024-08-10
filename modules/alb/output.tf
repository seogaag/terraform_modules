output "sg_alb_to_tg_id" {
  value = aws_security_group.sg-alb-to-tg.id
}

output "alb_dns_name" {
  value       = aws_lb.webserver_alb.dns_name
  description = "The domain name of the load balancer"
}
