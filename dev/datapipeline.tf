provider "aws" {
  region = "ap-south-1"
}

## 데이터 업로드

resource "aws_s3_bucket" "s3_stock" {
  bucket = "esia-stock-test"
}

resource "aws_s3_object" "s3_stock_raw_data" {
  for_each = fileset("../source/data/","**")
  bucket = aws_s3_bucket.s3_stock.bucket
  key = "raw/${each.value}"
  source = "../source/data/${each.value}"
}

##

# resource "aws_iam_role" "lambda_execution_role" {
#   name = "${var.service}_lambda_execution___role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "lambda_policy" {
#   name = "${var.service}_lambda_policy"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "s3:*",
#           "logs:*",
#           "sagemaker:*"
#         ],
#         Effect = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   policy_arn = aws_iam_policy.lambda_policy.arn
#   role     = aws_iam_role.lambda_execution_role.name
# }

module "lambda_preprocess" {
  source = "../modules/lambda"

  service = "esia-pre"
  bucket_arn = aws_s3_bucket.s3_stock.arn
  source_path = "../source"
  lambda_function_name = "ESIA_preprocess"
  lambda_file_name = "lambda_preprocess"
  lamda_layer_arns = ["arn:aws:lambda:ap-south-1:336392948345:layer:AWSSDKPandas-Python38:24"]
  lambda_env = {
    BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
    PREFIXES_LIST ="AAPL/, NVDA/"
  }
  memory_size = 256
  timeout = 60
}

module "lambda_training" {
  source = "../modules/lambda"

  service = "esia-train"
  bucket_arn = aws_s3_bucket.s3_stock.arn
  source_path = "../source"
  lambda_function_name = "ESIA_training"
  lambda_file_name = "lambda_training"
  lambda_env = {
    BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
    SAGEMAKER_ROLE = module.sagemaker.sagemaker_role_arn
  }
  memory_size = 256
  timeout = 60
  
}

# resource "aws_lambda_function" "model_evaluation" {
#   filename         = "../source/lambda_model_evaluation_payload.zip"
#   function_name    = "ModelEvaluationFunction"
#   role             = aws_iam_role.lambda_execution_role.arn
#   handler          = "index.handler"
#   runtime          = "python3.8"
# }

# resource "aws_lambda_function" "model_inference" {
#   filename         = "lambda_model_inference_payload.zip"
#   function_name    = "ModelInferenceFunction"
#   role             = aws_iam_role.lambda_execution_role.arn
#   handler          = "index.handler"
#   runtime          = "python3.8"
# }

resource "aws_sfn_state_machine" "workflow" {
  name     = "ModelTrainingAndEvaluation"
  role_arn  = module.lambda_training.lambda_role_arn

  definition = jsonencode({
    Comment = "State machine to preprocess data, train and evaluate model",
    StartAt = "PreprocessData",
    States = {
      PreprocessData = {
        Type = "Task",
        Resource = module.lambda_preprocess.lambda_function_arn,
        Next = "TrainModel",
        Parameters: {
          "companies": ["AAPL", "NVDA"]
        }
      },
      TrainModel = {
        Type = "Task",
        Resource = module.lambda_training.lambda_function_arn,
        # Next = "EvaluateModel",
        Parameters: {
          "companies": ["AAPL", "NVDA"]
        }
      }
#       EvaluateModel = {
#         Type = "Task",
#         Resource = aws_lambda_function.model_evaluation.arn,
#         End = true
#       },
#       GeneratePrediction = {
#         Type = "Task",
#         Resource = aws_lambda_function.model_inference.arn,
#         End = true
#       }
    }
  })
}
