resource "aws_iam_role" "lambda_role" {
    name = "uptime-monitor-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Service = "lambda.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_policy" "lambda_policy" {
    name = "uptime-monitor-policy"
    description = "Permissions for uptime monitor Lambda to write to DynamoDB + CloudWatch"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            Resource = [
                aws_dynamodb_table.uptime.arn
            ]
        }, {
            Effect = "Allow",
            Action = [
                "cloudwatch:PutMetricData"
            ],
            Resource = "*"
        }, {
            Effect = "Allow",
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource = "arn:aws:logs:*:*:*"
        }, {
            Effect = "Allow",
            Action = [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParameterHistory"
            ],
            Resource = aws_ssm_parameter.uptime_url_list.arn
        }]
    })
}


resource "aws_iam_role_policy_attachment" "attach_policy" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}


# AWS-managed policy for CloudWatch logs
resource "aws_iam_role_policy_attachment" "cw_logs" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}