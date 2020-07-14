variable "cidr" { type = list(string) }
variable "description" { type = string }
variable "outgoing" {
    type = list(object({
        cidr_blocks = list(string)
        from_port = number
        protocol = string
        to_port = number
    }))
}
variable "incoming" {
    type = list(object({
        cidr_blocks = list(string)
        from_port = number
        protocol = string
        to_port = number
    }))
}
variable "service" { type = string }
variable "vpc_id" { type = string }

locals {
    name = "${terraform.workspace}-${var.service}"
}

resource "aws_security_group" "group" {
  name = local.name
  description = var.description
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.incoming
    content {
      protocol = ingress.value.protocol
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.outgoing
    content {
      protocol = egress.value.protocol
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    terraform = "true"
    environment = terraform.workspace
  }
}

# EXPORTS
#########
output "id" {
    value = aws_security_group.group.id
}