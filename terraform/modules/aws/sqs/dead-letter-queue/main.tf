variable "delay_seconds" { type = number }
variable "max_message_size" { type = number }
variable "message_retention_seconds" { type = number }
variable "receive_wait_time_seconds" { type = number }
variable "topic" { type = string }

locals {
    name = "${var.topic}-${terraform.workspace}"
}

resource "aws_sqs_queue" "queue" {
    name = local.name
    delay_seconds = var.delay_seconds
    max_message_size = var.max_message_size
    message_retention_seconds = var.message_retention_seconds
    receive_wait_time_seconds = var.receive_wait_time_seconds
}

# EXPORTS
output "arn" {
    value = aws_sqs_queue.queue.arn
}