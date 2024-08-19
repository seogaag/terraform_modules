variable "service" {
  type = string
  default = "esia"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "cloudwatch_schedule" {
  type = string
  default = "rate(1 hour)"
}

variable "lambda_function_arn" {
    type = string
}