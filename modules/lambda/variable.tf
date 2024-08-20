variable "service" {
  type = string
  default = "esia"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "source_path" {
  type = string
  default = "../source"
}

variable "lambda_env" {
  type = map(string)
}

variable "memory_size" {
  type = number
}

variable "timeout" {
  type = number
}

variable "lambda_runtime" {
  type = string
  default = "python3.8"
}

variable "bucket_arn" {
  type = string
}

variable "lamda_layer_arns" {
  type = list(string)
  default = [  ]
}

variable "lambda_file_name" {
  type = string
}