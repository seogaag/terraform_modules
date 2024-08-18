variable "service" {
  type = string
}

# variable "image_uri" {
#   type = string
# }

# variable "container_entrypoint" {
#   type = list(string)
#   default = [ "python3" ]
# }

# variable "container_arguments" {
#   type = list(string)
# }

# variable "s3_key" {
#   type = string
# }

# variable "s3_sourcepath" {
#   type = string
# }

variable "domain_vpc_id" {
  type = string
}

variable "domain_subnet_ids" {
  type = list(string)
}