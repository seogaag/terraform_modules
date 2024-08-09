variable "alb_name" {
  type = string
  default = "ALB-"
}

variable "server_port" {
  type = number
  default = 80
}

# variable "internal_bool" {
#   type = bool
#   default = false
# }

variable "certificate_arn" {
  type = string
}

variable "port" {
  type = string
  default = "80"
}

variable "domain" {
  type = string
  default = ""
}

variable "hostzone_id" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "sg_allow_comm_list" {
  type = list
  default = ["0.0.0.0/0"]
}