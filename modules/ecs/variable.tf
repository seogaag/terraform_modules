variable "ecs_cluster_name" {
  type = string
}

variable "task_name" {
  type = string
}

variable "task_image" {
  type = string
}

variable "region" {
  type = string
  default = "ap-southeast-4"
}

variable "ecs_service_name" {
  type = string
}