resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"
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
  name        = "glue-policy"
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
        Resource = [
          "arn:aws:s3:::stock-data-*",
          "arn:aws:s3:::raw-stock-data-*",
          "arn:aws:s3:::processed-stock-data-*",
          "arn:aws:s3:::glue-scripts-*",
          "arn:aws:s3:::analysis-results-*"
        ]
      }
    ]
  })
}

# IAM 역할과 정책 연결
resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}