variable "policy_file" { 
    type = string
    default = ""
}
variable "redrive_policy" { 
    type = string
    default = ""
}
variable "topic" { type = string }

locals {
    name = "${var.topic}-${terraform.workspace}"
}

resource "aws_sqs_queue" "queue" {
    name = local.name
    policy = var.policy_file != "" ? var.policy_file : null
    redrive_policy = var.redrive_policy != "" ? var.redrive_policy : null
}

# EXPORTS
output "arn" {
    value = aws_sqs_queue.queue.arn
}