# S3 Bucket 생성
resource "aws_s3_bucket" "lambda_bucket" {
    bucket = var.bucket_name
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
  name   = "${var.service}_lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.lambda_bucket.arn}/*"
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
resource "aws_lambda_function" "lambda_function" {
  filename         = "${var.source_path}/${var.lambda_function_name}_payload.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "${var.lambda_function_name}.${var.lambda_function_name}"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${var.source_path}/${var.lambda_function_name}_payload.zip")

  environment {
    variables = var.lambda_env
  }

  memory_size = var.memory_size
  timeout     = var.timeout
}

# Lambda 함수에 대한 CloudWatch Event 규칙 생성
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name        = "${var.service}_clodwatch_event_rule"
  schedule_expression = var.cloudwatch_schedule # "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  arn       = aws_lambda_function.lambda_function.arn

}

# Lambda 함수 권한 추가
resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_event_rule.arn
}
