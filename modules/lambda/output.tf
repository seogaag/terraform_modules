output "bucket_name_raw" {
  value = aws_s3_bucket.stock_data.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.stock_collector.function_name
}
