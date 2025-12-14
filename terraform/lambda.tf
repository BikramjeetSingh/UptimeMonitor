resource "aws_lambda_function" "uptime" {
    function_name = "uptime-monitor"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.10"
    filename = var.lambda_zip_path
    source_code_hash = filebase64sha256(var.lambda_zip_path)
    role = aws_iam_role.lambda_role.arn

    environment {
        variables = {
            UPTIME_TABLE = aws_dynamodb_table.uptime.name
            UPTIME_SSM_PARAM = var.uptime_ssm_param
        }
    }


    tags = {
        Project = "uptime-monitor"
    }
}