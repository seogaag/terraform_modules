# Lambda 함수에 대한 CloudWatch Event 규칙 생성
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name        = "${var.service}_clodwatch_event_rule"
  schedule_expression = var.cloudwatch_schedule
}

# CloudWatch Events 규칙과 Step Function을 연결
resource "aws_cloudwatch_event_target" "cloudwatch_function" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  arn       = var.cloudwatch_event_target_arn
  role_arn  = aws_iam_role.cloudwatch_role.arn
}

# # Lambda 함수 권한 추가
# resource "aws_lambda_permission" "allow_cloudwatch" {
#   action        = "lambda:InvokeFunction"
#   function_name = var.lambda_function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.cloudwatch_event_rule.arn
# }
