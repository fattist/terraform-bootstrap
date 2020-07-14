variable "name" {}

resource "aws_cloudwatch_log_group" "group" {
    name = var.name

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

# EXPORTS
#########
output "arn" {
    value = aws_cloudwatch_log_group.arn
}

# TODO TEST