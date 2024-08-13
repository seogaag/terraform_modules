variable "service_name" {
    description = "service name"
    type        = string
}

variable "user_name" {
    description = "user name"
    type        = string
}

// security guide

variable "description" {
    description = "Description for security group"
    type        = string
    default     = "All Pass"
}

variable "cidr_block_all" {
    description = "cidr block for all"
    type        = string
    default     = "0.0.0.0/0"
}

// vpc

variable "vpc_id" {
    description = "vpc id"
    type        = string
}

// ingress egress

variable "ingress_rule" {
    description = "ingress rules"
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks  = list(string)
    }))
    default = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = [ "0.0.0.0/0" ]
    }]
}

variable "egress_rule" {
    description = "egress rules"
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks  = list(string)
    }))
    default = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = [ "0.0.0.0/0" ]
    }]
}
