variable "capacity" {
    type = object({
        min = number
        max = number
    })
}

variable "config" {
    type = list(object({
        target_value = number
        predefined_metric_type = string
    }))
}

variable "policy_type" { type = string }
variable "resource_id" { type = string }
variable "role_arn" { type = string }
variable "scalable_dimension" { type = string }
variable "service_namespace" { type = string }

resource "aws_appautoscaling_target" "target" {
    max_capacity = var.capacity.max
    min_capacity = var.capacity.min
    resource_id = var.resource_id
    role_arn = var.role_arn
    scalable_dimension = var.scalable_dimension
    service_namespace = var.service_namespace
}

resource "aws_appautoscaling_policy" "policy" {
    name = "${var.scalable_dimension}:${aws_appautoscaling_target.target.resource_id}"
    policy_type = var.policy_type
    resource_id = aws_appautoscaling_target.target.resource_id
    scalable_dimension = aws_appautoscaling_target.target.scalable_dimension
    service_namespace = aws_appautoscaling_target.target.service_namespace

    dynamic "target_tracking_scaling_policy_configuration" {
        for_each = var.config
        content {
            target_value = target_tracking_scaling_policy_configuration.value.target_value
            predefined_metric_specification {
                predefined_metric_type = target_tracking_scaling_policy_configuration.value.predefined_metric_type
            }
        }
    }
}