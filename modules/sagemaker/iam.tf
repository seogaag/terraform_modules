resource "aws_iam_role" "sagemaker_role" {
  name = "${var.service}-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_policy" {
  name = "${var.service}-sagemaker-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "*"
          # "${var.sage_bucket_arn}",
          # "${var.sage_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect: "Allow",
        Action: "iam:PassRole",
        Resource: "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreateTrainingJob",
          "sagemaker:CreateModel",
          "sagemaker:CreateEndpointConfig",
          "sagemaker:CreateEndpoint",
          "sagemaker:InvokeEndpoint",
          "sagemaker:CreatePresignedDomainUrl",
          "sagemaker:AddTags",
          "sagemaker:ListApps",
          "sagemaker:ListDomains",
          "sagemaker:ListUserProfiles",
          "sagemaker:ListSpaces",
          "sagemaker:DescribeApp",
          "sagemaker:DescribeDomain",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DescribeSpace",
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace",
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
  # depends_on = [ aws_s3_bucket.sagemaker_bucket ]
}

resource "aws_iam_role_policy_attachment" "sagemaker_role_policy_attachment" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}
