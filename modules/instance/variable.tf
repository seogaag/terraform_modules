variable "ami_id" {
  description = "ami (default: Amazone Linux)"
  type = string
  default = "ami-0790a5dc816e4a98f"
}

variable "associate_public_ip_address" {
  description = "associate public ip true/false"
  type = bool
  default = "false"
}

variable "instance_type" {
  description = "instance type"
  type = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "ec2_volume_size" {
  type = number
  default = 20
}

variable "user_data" {
  type = string
  default = ""
}

variable "ec2_name" {
  type = string
  default = "ec2"
}

variable "vpc_id" {
  type = string
}

variable "sg_port_list" {
  type = list(number)
  default = [ 22, 80, 443 ]
}

variable "sg_cidr_blocks" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}