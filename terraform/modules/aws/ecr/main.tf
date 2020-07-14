variable "service" { type = string }

locals {
    name = "${var.service}-${terraform.workspace}"
}

resource "aws_ecr_repository" "repository" {
  name = local.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    terraform = "true"
    environment = terraform.workspace
  }
}

# EXPORTS
#########
output "arn" {
    value = aws_ecr_repository.repository.arn
}

output "name" {
    value = aws_ecr_repository.repository.name
}

output "url" {
    value = aws_ecr_repository.repository.repository_url
}