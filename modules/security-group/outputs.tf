output "security_group" {
    value = aws_security_group.security_group
}

output "security_group_id" {
    value = aws_security_group.security_group.id
}

