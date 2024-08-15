resource "aws_iam_role" "glue_service_role" {
  name = "esia-glue_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}


# IAM 정책 생성
resource "aws_iam_policy" "glue_policy" {
  name        = "esia-glue-policy"
  description = "Policy for Glue service to access S3 buckets"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = var.glue_s3_resource_arns
      }
    ]
  })
}

# IAM 역할과 정책 연결
resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}