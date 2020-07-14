variable "enabled" {
    type = bool
    default = true
}
variable "endpoint" { type = string }
variable "policy_file" {
    type = string
    default = ""
}
variable "protocol" {
    type = string
    default = "https"
}
variable "topic" { type = string }

locals {
    name = "${var.topic}-${terraform.workspace}"
}

resource "aws_sns_topic" "topic" {
    count = var.enabled ? 1 : 0
    display_name = local.name
    name = local.name

    policy = var.policy_file != "" ? var.policy_file : null
}

resource "aws_sns_topic_subscription" "subscription" {
    count = var.enabled ? 1 : 0
    topic_arn = aws_sns_topic.topic[0].arn
    protocol = var.protocol
    endpoint = var.endpoint
    endpoint_auto_confirms = true
    depends_on = [aws_sns_topic.topic]
}

# EXPORTS
output "arn" {
    value = length(aws_sns_topic.topic) > 0 ? aws_sns_topic.topic[0].arn : null
}
output "id" {
    value = length(aws_sns_topic.topic) > 0 ? aws_sns_topic.topic[0].id : null
}