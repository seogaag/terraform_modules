# provider "aws" {
#   region = "ap-south-1"
# }

# # ## 데이터 업로드

# resource "aws_s3_bucket" "s3_stock" {
#   bucket = "esia-stock-test-j"
# }

# resource "aws_s3_object" "s3_stock_raw_data" {
#   for_each = fileset("../source/data/","**")
#   bucket = aws_s3_bucket.s3_stock.bucket
#   key = "raw/${each.value}"
#   source = "../source/data/${each.value}"
# }

# ##

# # resource "aws_iam_role" "lambda_execution_role" {
# #   name = "${var.service}_lambda_execution___role"
# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17",
# #     Statement = [
# #       {
# #         Action = "sts:AssumeRole",
# #         Effect = "Allow",
# #         Principal = {
# #           Service = "lambda.amazonaws.com"
# #         }
# #       }
# #     ]
# #   })
# # }

# # resource "aws_iam_policy" "lambda_policy" {
# #   name = "${var.service}_lambda_policy"
# #   policy = jsonencode({
# #     Version = "2012-10-17",
# #     Statement = [
# #       {
# #         Action = [
# #           "s3:*",
# #           "logs:*",
# #           "sagemaker:*"
# #         ],
# #         Effect = "Allow",
# #         Resource = "*"
# #       }
# #     ]
# #   })
# # }

# # resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
# #   policy_arn = aws_iam_policy.lambda_policy.arn
# #   role     = aws_iam_role.lambda_execution_role.name
# # }



# module "lambda_collector" {
#   source = "../modules/lambda"

#   service = "esia-col"
#   bucket_arn = aws_s3_bucket.s3_stock.arn
#   source_path = "../source"
#   lambda_function_name = "ESIA_collector"
#   lambda_file_name = "lambda_collector"
#   lamda_layer_arns = ["arn:aws:lambda:ap-south-1:336392948345:layer:AWSSDKPandas-Python38:24"]
#   lambda_env = {
#     BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
#     API_KEY="QE0t8vHW3Ndx82q30U_qiZMOQc0kRrl6"
#   }
#   sagemaker_role_arn = module.sagemaker.sagemaker_role_arn
# }

# module "lambda_preprocess" {
#   source = "../modules/lambda"

#   service = "esia-pre"
#   bucket_arn = aws_s3_bucket.s3_stock.arn
#   source_path = "../source"
#   lambda_function_name = "ESIA_preprocess"
#   lambda_file_name = "lambda_preprocess"
#   lamda_layer_arns = ["arn:aws:lambda:ap-south-1:336392948345:layer:AWSSDKPandas-Python38:24"]
#   lambda_env = {
#     BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
#   }

#   sagemaker_role_arn = module.sagemaker.sagemaker_role_arn
# }

# module "lambda_training" {
#   source = "../modules/lambda"

#   service = "esia-train"
#   bucket_arn = aws_s3_bucket.s3_stock.arn
#   source_path = "../source"
#   lambda_function_name = "ESIA_training"
#   lambda_file_name = "lambda_training"
#   lambda_env = {
#     BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
#     SAGEMAKER_ROLE = module.sagemaker.sagemaker_role_arn
#   }
#   sagemaker_role_arn = module.sagemaker.sagemaker_role_arn
# }

# # module "lambda_waittraining" {
# #   source = "../modules/lambda"

# #   service = "esia-wait"
# #   bucket_arn = aws_s3_bucket.s3_stock.arn
# #   source_path = "../source"
# #   lambda_function_name = "ESIA_waiting"
# #   lambda_file_name = "lambda_waittraining"
# #   lambda_env = {}
# #   sagemaker_role_arn = module.sagemaker.sagemaker_role_arn
# # }



# module "lambda_evaluation" {
#   source = "../modules/lambda"

#   service = "esia-eval"
#   bucket_arn = aws_s3_bucket.s3_stock.arn
#   source_path = "../source"
#   lambda_function_name = "ESIA_evaluation"
#   lambda_file_name = "lambda_evaluation"
#   # lamda_layer_arns = [aws_lambda_layer_version.lambda_layer_numpy.arn]
#   lambda_env = {
#     BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
#     SAGEMAKER_ROLE = module.sagemaker.sagemaker_role_arn
#   }
#   timeout = 900
#   sagemaker_role_arn = module.sagemaker.sagemaker_role_arn
# }

# module "lambda_output" {
#   source = "../modules/lambda"

#   service = "esia-output"
#   bucket_arn = aws_s3_bucket.s3_stock.arn
#   source_path = "../source"
#   lambda_function_name = "ESIA_prediction"
#   lambda_file_name = "lambda_output"
#   lambda_env = {
#     BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
#   }
#   sagemaker_role_arn = module.sagemaker.sagemaker_role_arn
# }

# locals {
#   company_list = ["AAPL", "NVDA"]
# }

# resource "aws_sfn_state_machine" "workflow" {
#   name     = "ModelTrainingAndEvaluation"
#   role_arn  = module.lambda_training.lambda_role_arn

#   definition = jsonencode({
#     Comment = "State machine to preprocess data, train and evaluate model",
#     StartAt = "CollectData",
#     States = {
#       CollectData = {
#         Type = "Task",
#         Resource = module.lambda_collector.lambda_function_arn
#         Next = "PreprocessData",
#         Parameters: {
#           # "companies": ["AAPL", "NVDA"]
#           "companies": local.company_list
#         }
#       }
#       PreprocessData = {
#         Type = "Task",
#         Resource = module.lambda_preprocess.lambda_function_arn,
#         Next = "TrainModel",
#         Parameters: {
#           "companies": local.company_list
#         }
#       },
#       TrainModel = {
#         Type = "Task",
#         Resource = module.lambda_training.lambda_function_arn,
#         Next = "Wait",
#         Parameters: {
#           "companies": local.company_list
#         }
#       },
#       Wait = {
#         Type = "Wait",
#         Seconds = 480,  # 8분 동안 대기
#         Next = "EvaluateModel"
#       },
#       EvaluateModel = {
#         Type = "Task",
#         Resource = module.lambda_evaluation.lambda_function_arn,
#         Parameters: {
#           "companies": local.company_list
#         },
#         Next = "GetPrediction"
#       }
#       GetPrediction = {
#         Type = "Task",
#         Resource = module.lambda_output.lambda_function_arn,
#         Parameters: {
#           "companies": local.company_list
#         },
#         End = true
#       }
#     }
#   })
#   depends_on = [ 
#     module.lambda_collector, 
#     module.lambda_preprocess, 
#     module.lambda_training,
#     module.lambda_evaluation,
#     module.lambda_output ]
# }

# module "daily_raw_cloudwatch" {
#   source = "../modules/cloudwatch_event"

#   service = var.service
#   cloudwatch_schedule = "cron(30 11 ? * MON-FRI *)"
#   cloudwatch_event_target_arn = aws_sfn_state_machine.workflow.arn
  
#   depends_on = [ aws_sfn_state_machine.workflow ]
# }