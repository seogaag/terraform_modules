variable "ecr_name" {
  type= string
}

variable "ecr_image_tag_mutability" {
  type = string
  default = "IMMUTABLE"
}

variable "image_scan_on_push" {
  type = bool
  default = false
}

variable "ecr_allow_account_arns" {
  type        = list(string)
  description = "Allow account to ECR pull"
}

variable "ecr_force_delete" {
  type = bool
}