variable "compatibilities" {
    type = list(string)
    default = ["FARGATE"]
}
variable "cpu" { type = number }
variable "execution_role_arn" { type = string }
variable "image" { type = string }
variable "memory" { type = number }
variable "mode" {
  type = string
  default = "awsvpc"
}
variable "name" { type = string }
variable "port" { type = number }
variable "region" { type = string }

data "aws_ecs_task_definition" "current" {
  depends_on = [aws_ecs_task_definition.definition]
  task_definition = aws_ecs_task_definition.definition.family
}

resource "aws_ecs_task_definition" "definition" {
  family = var.name
  network_mode = var.mode
  requires_compatibilities = var.compatibilities
  cpu = var.cpu
  memory = var.memory
  execution_role_arn = var.execution_role_arn

  container_definitions = templatefile("${path.module}/tpl/service.tpl", {
    containerPort = var.port
    cpu = var.cpu
    environment = terraform.workspace
    hostPort = var.port
    image = "${var.image}:latest"
    memory = var.memory
    networkMode = var.mode
    region = var.region
    service = var.name
  })
}

# EXPORTS
#########
output "data_revision" {
    value = data.aws_ecs_task_definition.current.revision
}

output "definition_revision" {
    value = aws_ecs_task_definition.definition.revision
}

output "family" {
    value = aws_ecs_task_definition.definition.family
}