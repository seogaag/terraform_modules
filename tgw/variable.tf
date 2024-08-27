variable "region_1" {
  default = "ap-southeast-4"
}

variable "region_2" {
  default = "ap-south-1"
}

variable "region_3" {
  # main
  default = "us-west-1"
}

variable "ips" {
  default = ["10.0.0.0/8"]
}

variable "protocols" {
  default = ["HTTP", "SSH", "IP"]
}

variable "service" {
  default = "esia"
}

locals {
  service = "esia"
}

variable "protocols" {
  type = list(string)
  default = ["HTTP", "SSH", "IP"]
}