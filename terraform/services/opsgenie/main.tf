variable "enabled" {
    type = bool
    default = true
}
variable "endpoint" { type = string }
variable "topic" {
    type = string
    default = "opsgenie"
}

module "sns" {
    source = "../../modules/aws/sns"
    enabled = var.enabled
    endpoint = var.endpoint
    topic = var.topic
}

# EXPORTS
output "sns_arn" {
    value = module.sns.arn
}

output "sns_id" {
    value = module.sns.id
}
