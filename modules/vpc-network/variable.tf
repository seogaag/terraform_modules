variable "region" {
  default = "ap-south-1"
}

variable "cidr_blocks" {
  type = list(string)
  default = [ "192.118.0.0/16", "10.2.0.0/16","10.3.0.0/16", "10.4.0.0/16" ]
}

variable "cidr_block_all" {
  type = string
  default = "0.0.0.0/0"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "account_name" {
  default = "network"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}