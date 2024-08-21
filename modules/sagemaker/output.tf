# output "sagemaker_notebook_url" {
#   value = aws_sagemaker_notebook_instance.sagemaker_notebook_instance.url
# }

output "sagemaker_role_arn" {
  value = aws_iam_role.sagemaker_role.arn
}