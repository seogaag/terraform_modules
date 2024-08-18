# Lambda 함수에 대한 CloudWatch Event 규칙 생성
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name        = "${var.service}_clodwatch_event_rule"
  schedule_expression = var.cloudwatch_schedule # "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  arn       = aws_lambda_function.lambda_function.arn

}

# Lambda 함수 권한 추가
resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_event_rule.arn
}
