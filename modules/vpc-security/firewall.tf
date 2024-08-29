## network firewall

resource "aws_networkfirewall_rule_group" "rule_group" {
  capacity = 50
  name = "rule_group"
  type = "STATEFUL"
  rule_group {
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.protocols
        content {
          action = "PASS"
          header {
            destination = "ANY"
            destination_port = "ANY"
            protocol = stateful_rule.value # "HTTP" # + IP, SSH
            direction = "ANY"
            source_port = "ANY"
            source = var.ips
          }
          rule_option {
            keyword = "sid"
            settings = ["1"]
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "Firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.rule_group.arn
    }
    tls_inspection_configuration_arn = "arn:aws:network-firewall:ap-southeast-4:381492185710:tls-configuration/example"
  }

  depends_on = [ aws_networkfirewall_rule_group.rule_group ]
}

resource "aws_networkfirewall_firewall" "networkfirewall" {
  name = "Firewall-${var.account_name}-${var.region}"
  vpc_id = aws_vpc.my_vpc.id
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall_policy.arn
  subnet_mapping { # 변수로 
    subnet_id = aws_subnet.sub_firewall.id
  }
}

resource "aws_s3_bucket" "networkfirewall_log_FLOW" {
  bucket = "s3-${var.service}-networkfirewall-log-FLOW"
}
resource "aws_s3_bucket" "networkfirewall_log_ALERT" {
  bucket = "s3-${var.service}-networkfirewall-log-ALERT"
}


resource "aws_networkfirewall_logging_configuration" "logging" {
  firewall_arn = aws_networkfirewall_firewall.networkfirewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        bucketName = aws_s3_bucket.networkfirewall_log_FLOW.bucket
        prefix     = "/"
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        bucketName = aws_s3_bucket.networkfirewall_log_ALERT.bucket
        prefix = "/"
      }
      log_destination_type = "S3"
      log_type = "ALERT"
    }
  }
}