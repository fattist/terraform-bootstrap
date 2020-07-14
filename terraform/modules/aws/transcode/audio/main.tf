variable "input_bucket" { type = string }
variable "name" { type = string }
variable "output_bucket" { type = string }
variable "role" { type = string }

locals {
    name = "${var.name}-${terraform.workspace}"
}

resource "aws_elastictranscoder_pipeline" "transcoder" {
    input_bucket = var.input_bucket
    name = local.name
    output_bucket = var.output_bucket
    role = var.role
}