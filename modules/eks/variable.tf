variable "eks_cluster_name" {
  type = string
}

variable "eks_sub_ids" {
  type = list(string)
}

variable "eks_node_group_name" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
  default = ["t3.medium"]
}

variable "node_disk_size" {
  type = number
  default = 20
}

variable "node_sub_ids" {
  type= list(string)
}

variable "vpc_id" {
  type = string
}

variable "sg_port_list" {
  type = list(number)
  default = [ 0 ]
}

variable "sg_cidr_blocks" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "eks_security_groups_ids" {
  type = list(string)
}