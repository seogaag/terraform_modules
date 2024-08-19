

# resource "aws_s3_object" "data_processing_script" {
#   bucket = aws_s3_bucket.sagemaker_bucket.bucket
#   key    = var.s3_key
#   source = var.s3_sourcepath
# }

# #######################
# resource "aws_sagemaker_processing_job" "sagemaker_processing" {
#   processing_job_name = "${var.service}_sagemaker_processing_job"
#   role_arn = aws_iam_role.sagemaker_role

#   app_specification {
#     image_uri = var.processing_image_uri
#     container_entrypoint = var.container_entrypoint
#     container_arguments = var.container_arguments
#   }

#   processing_resources  {
#     cluster_config {
#         instance_count = 1
#         instance_type = "m1.m5.xlarge"
#         volume_size_in_gb = 10
#     }
#   }

#   processing_input { # 저장할 s3
#     input_name = "input"
#     s3_input {
#         s3_uri = "s3://${aws_s3_bucket.sagemaker_data.bucket}/raw_data/"
#         local_path = "/opt/ml/processing/input"
#         s3_data_type = "S3Prefix"
#         s3_input_mode = "File"
#     }
#   }

#   processing_output {
#     output {
#         output_naame = "output"
#         s3_output {
#             s3_uri = "s3://${aws_s3_bucket.sagemaker_data.bucket}/golden_data/"
#             local_path = "/opt/ml/processing/input"
#         }
#     }
#   }

#   stopping_condition {
#     max_runtime_in_seconds = 3600
#   }
# }


# variable "image_uri" {
#   type = string
# }

# variable "container_entrypoint" {
#   type = list(string)
#   default = [ "python3" ]
# }

# variable "container_arguments" {
#   type = list(string)
# }

# variable "s3_key" {
#   type = string
# }

# variable "s3_sourcepath" {
#   type = string
# }