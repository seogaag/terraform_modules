output "instance_id" {
  value = aws_instance.ec2.id
}

output "instance_az" {
  value = aws_instance.ec2.availability_zone
}