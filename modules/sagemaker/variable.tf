variable "service" {
  type = string
}

variable "domain_vpc_id" {
  type = string
}

variable "domain_subnet_ids" {
  type = list(string)
}

variable "sage_bucket" {
  type = string
}

variable "sage_bucket_arn" {
  type = string
}