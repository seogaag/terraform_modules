
locals {
  service = "esia"
}

variable "protocols" {
  type = list(string)
  default = ["HTTP", "SSH", "IP"]
}

variable "ips" {
  type = string
  default = "10.0.0.0/8"
}

variable "firewall_subnet_id" {
  type = string
}