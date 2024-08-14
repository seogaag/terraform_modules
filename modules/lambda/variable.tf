variable "service" {
  type = string
  default = "esia"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "cloudwatch_schedule" {
  type = string
  default = "rate(1 hour)"
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