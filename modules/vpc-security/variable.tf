variable "region" {
  default = "ap-south-1"
}

variable "service" {
  type = string
  default = "esia"
}

variable "account_name" {
  type = string
  default = "security"
}

# variable "cidr_blocks" {
#   type = list(string)
#   default = [ "192.118.0.0/16", "10.2.0.0/16","10.3.0.0/16", "10.4.0.0/16" ]
# }

variable "cidr_block_all" {
  type = string
  default = "0.0.0.0/0"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.1.0.0/16"
}

variable "protocols" {
  type = list(string)
  default = ["HTTP", "SSH", "IP"]
}

variable "ips" {
  type = string
  default = "10.0.0.0/8"
}

# variable "access_key" {
#   type = string
# }

# variable "secret_key" {
#   type = string
# }
