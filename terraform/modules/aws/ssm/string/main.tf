variable "service" {
    type = string
}

variable "value" {
    type = string
}

locals {
    name = "/${terraform.workspace}/${var.service}"
} 

resource "aws_ssm_parameter" "parameter" {
    name = local.name
    type = "String"
    value = var.value

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}