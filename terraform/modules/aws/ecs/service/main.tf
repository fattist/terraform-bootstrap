variable "cluster" { type = string }
variable "data_revision" { type = string }
variable "definition_revision" { type = string }
variable "desired_count" {
    type = number
    default = 1
}
variable "family" { type = string }
variable "launch_type" {
    type = string
    default = "FARGATE"
}
variable "name" { type = string }
variable "port" { type = number }
variable "container_security_groups" { type = list(string) }
variable "subnets" { type = list(string) }
variable "target_group_arn" { type = string }

resource "aws_ecs_service" "service" {
  name = var.name
  cluster = var.cluster
  task_definition = "${var.family}:${max(var.definition_revision, var.data_revision)}"
  desired_count = var.desired_count
  launch_type = var.launch_type

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds = 300

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  network_configuration {
    security_groups = var.container_security_groups
    subnets = var.subnets
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = var.name
    container_port = var.port
  }
}