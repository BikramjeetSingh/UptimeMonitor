resource "aws_ssm_parameter" "uptime_url_list" {
    name = var.uptime_ssm_param
    description = "List of URLs monitored by the uptime monitor (comma-separated)"
    type = "String"
    value = " "

    lifecycle {
        ignore_changes = [
            value
        ]
    }

    tags = {
        Project = "uptime-monitor"
    }
}