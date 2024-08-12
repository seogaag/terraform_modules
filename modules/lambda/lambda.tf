# S3 Bucket 생성
resource "aws_s3_bucket" "stock_data" {
#   bucket_prefix = "stock-data-"
    bucket = var.bucket_name_raw
}

# Lambda 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda 역할 정책 생성
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.stock_data.arn}/*"
      },
      {
        Action   = "logs:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Lambda 함수 생성
resource "aws_lambda_function" "stock_collector" {
  filename         = "../source/lambda_function_payload.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      API_KEY = var.api_key
      SYMBOL  = var.symbols
    }
  }
}

# Lambda 함수에 대한 CloudWatch Event 규칙 생성
resource "aws_cloudwatch_event_rule" "every_hour" {
  name        = "every-hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_hour.name
  arn       = aws_lambda_function.stock_collector.arn

}

# Lambda 함수 권한 추가
resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock_collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_hour.arn
}
