# Lambda 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "${var.service}_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Effect: "Allow",
        Principal: {
          Service: "states.amazonaws.com"
        },
        Action: "sts:AssumeRole"
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
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:*"
        ],
        Effect   = "Allow",
        Resource = "${var.bucket_arn}/*"
      },
      {
        Action   = [
          "s3:*",
          "logs:*",
          "sagemaker:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Effect: "Allow",
        Action: "iam:PassRole",
        Resource: "arn:aws:iam::381492185710:role/esia-test_sagemaker_role"
      },
      {
        Effect: "Allow",
        Action: "lambda:InvokeFunction",
        Resource: "arn:aws:lambda:ap-south-1:381492185710:function:*"
      } 
    ]
  })
}

# Lambda 함수 생성
resource "aws_lambda_function" "lambda_function" {
  filename         = "${var.source_path}/${var.lambda_file_name}_payload.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  # handler          = "${var.lambda_function_name}.${var.lambda_function_name}"
  handler = "${var.lambda_file_name}.handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${var.source_path}/${var.lambda_file_name}_payload.zip")

  layers = var.lamda_layer_arns

  environment {
    variables = var.lambda_env
  }

  memory_size = var.memory_size
  timeout     = var.timeout
}

