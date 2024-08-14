resource "aws_ecr_repository" "ecr" {
  name                 = var.ecr_name
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push
  }
  
  lifecycle {
    prevent_destroy = false
  }

  force_delete = var.ecr_force_delete
}


## iam
data "aws_iam_policy_document" "ecr-repository-policy" {
  statement {
    sid    = "AllowPull"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.ecr_allow_account_arns
    }
    actions = [
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:ListImages",
        "ecr:DescribeRepositories",
        "ecr:ListTagsForResource"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr-policy" {
  repository = var.ecr_name
  depends_on = [aws_ecr_repository.ecr]
  policy     = data.aws_iam_policy_document.ecr-repository-policy.json
}
