variable "aws_region" {
    type = string
    default = "us-west-2"
}


variable "aws_profile" {
    type = string
    default = "personal"
}


variable "lambda_zip_path" {
    type = string
    default = "../uptime_lambda.zip"
}


variable "uptime_ssm_param" {
    type = string
    description = "Name of the SSM parameter containing the URL list"
    default = "/uptime-monitor/url-list"
}