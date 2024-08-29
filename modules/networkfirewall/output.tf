output "firewall_endpoint_id" {
    value = aws_networkfirewall_firewall.networkfirewall.firewall_status.sync_states.attachment.endpoint_id
}