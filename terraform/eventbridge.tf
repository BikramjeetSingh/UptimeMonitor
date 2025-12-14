resource "aws_cloudwatch_event_rule" "schedule" {
    name = "uptime-monitor-rule"
    schedule_expression = "rate(5 minutes)"
}


resource "aws_cloudwatch_event_target" "lambda_target" {
    rule = aws_cloudwatch_event_rule.schedule.name
    arn = aws_lambda_function.uptime.arn
    target_id = "uptime-lambda"
}


resource "aws_lambda_permission" "allow_eventbridge" {
    statement_id = "AllowExecutionFromEventBridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.uptime.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.schedule.arn
}