provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "s3_stock" {
  bucket = "esia-stock"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.service}_lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.service}_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*",
          "logs:*",
          "sagemaker:*"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role     = aws_iam_role.lambda_execution_role.name
}

resource "aws_lambda_function" "preprocess" {
  filename         = "../source/lambda_preprocess_payload.zip"
  function_name    = "PreprocessFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
}

resource "aws_lambda_function" "model_training" {
  filename         = "../source/lambda_model_training_payload.zip"
  function_name    = "ModelTrainingFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
}

resource "aws_lambda_function" "model_evaluation" {
  filename         = "../source/lambda_model_evaluation_payload.zip"
  function_name    = "ModelEvaluationFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
}

resource "aws_lambda_function" "model_inference" {
  filename         = "lambda_model_inference_payload.zip"
  function_name    = "ModelInferenceFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
}

resource "aws_sfn_state_machine" "workflow" {
  name     = "ModelTrainingAndEvaluation"
  role_arn  = aws_iam_role.lambda_execution_role.arn

  definition = jsonencode({
    Comment = "State machine to preprocess data, train and evaluate model",
    StartAt = "PreprocessData",
    States = {
      PreprocessData = {
        Type = "Task",
        Resource = aws_lambda_function.preprocess.arn,
        Next = "TrainModel"
      },
      TrainModel = {
        Type = "Task",
        Resource = aws_lambda_function.model_training.arn,
        Next = "EvaluateModel"
      },
      EvaluateModel = {
        Type = "Task",
        Resource = aws_lambda_function.model_evaluation.arn,
        End = true
      },
      GeneratePrediction = {
        Type = "Task",
        Resource = aws_lambda_function.model_inference.arn,
        End = true
      }
    }
  })
}
