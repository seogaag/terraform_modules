variable "region_1" {
  default = "ap-southeast-4"
}

variable "region_2" {
  default = "ap-south-1"
}

variable "ips" {
  default = ["10.1.0.0/16", "100.64.0.0/26",
             "10.2.0.0/16", "100.64.1.0/26"]
}

variable "protocols" {
  default = ["HTTP", "SSH", "IP"]
}