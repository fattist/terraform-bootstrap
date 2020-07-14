variable "service" { type = string }

locals {
  name = "${var.service}-${terraform.workspace}"
}

resource "aws_ecs_cluster" "cluster" {
  name = local.name
  capacity_providers = ["FARGATE"]

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = {
    terraform = "true"
    environment = terraform.workspace
  }
}

# EXPORTS
#########
output "arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "id" {
  value = aws_ecs_cluster.cluster.id
}