variable "service" {
    type = string
}

variable "value" {
    type = list(string)
}

locals {
    name = "/${terraform.workspace}/${var.service}"
} 

resource "aws_ssm_parameter" "parameter" {
    name = local.name
    type = "StringList"
    value = join(",", var.value)

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}