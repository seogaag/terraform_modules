variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "api_key" {
  description = "API key for accessing the stock data API"
  type        = string
}

variable "symbols" {
  description = "Stock symbol to fetch data for"
  type        = string
}
