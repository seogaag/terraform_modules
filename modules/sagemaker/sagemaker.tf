# resource "aws_sagemaker_model" "sagemaker_model" {
#   name                = "${var.service}-sagemaker-model"
#   execution_role_arn  = aws_iam_role.sagemaker_role.arn

#   primary_container {
#     image = "991648021394.dkr.ecr.ap-south-1.amazonaws.com/forecasting-deepar:latest"
#     mode = "SingleModel"
#     model_data_url = "s3://${var.sage_bucket}/model_output/model.tar.gz"
#   }
# }

# resource "aws_sagemaker_model_package_group" "sagemaker_model_package_group" {
#   model_package_group_name = "${var.service}-model-package-group"
  
# }

# resource "aws_sagemaker_endpoint_configuration" "sagemaker_endpoint_configuration" {
#   name = "${var.service}-endpoint-config"

#   production_variants {
#     variant_name     = "AllTraffic"
#     model_name       = aws_sagemaker_model.sagemaker_model.name
#     instance_type    = "ml.m5.large"
#     initial_instance_count = 1
#   }
# }

# resource "aws_sagemaker_endpoint" "sagemaker_endpoint" {
#   name                = "${var.service}-endpoint"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.sagemaker_endpoint_configuration.name
# }

# resource "aws_sagemaker_domain" "sagemaker_domain" {
#   domain_name = "${var.service}-studio-domain"
#   auth_mode    = "IAM"

#   vpc_id = var.domain_vpc_id
#   subnet_ids = var.domain_subnet_ids

#   default_user_settings {
#     execution_role = aws_iam_role.sagemaker_role.arn
#   }
# }

# resource "aws_sagemaker_user_profile" "profile" {
#   domain_id          = aws_sagemaker_domain.sagemaker_domain.id
#   user_profile_name  = "${var.service}-user-profile"
# }

# # resource "aws_sagemaker_notebook_instance" "sagemaker_notebook_instance" {
# #   name = "${var.service}-notebook-instance"
# #   instance_type = "ml.t2.medium"
# #   role_arn = aws_iam_role.sagemaker_role.arn
# # }

