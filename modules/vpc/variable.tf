variable "region" {
  description = "AWS region"
  type = string
}

variable "vpc_cidr" {
  description = "vpc cidr block"
  type = string
}

variable "vpc_name" {
  description = "vpc name"
  type = string
}

variable "subnet_names" {
  description = "subnet name list"
  type = list(string)
}

variable "igw_name" {
  description = "Internet GateWay name"
  type = string
}

variable "ngw_names" {
  description = "Nat GateWay name list"
  type = list(string)
}
