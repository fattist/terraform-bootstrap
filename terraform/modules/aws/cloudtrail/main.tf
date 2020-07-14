variable "bucket" { type = string }
variable "name" { type = string }
variable "selectors" { 
    type = list(object({
      type = string
      values = list(string)
    }))
}

locals {
    name = "terraform-${var.name}-${terraform.workspace}"
}

resource "aws_cloudtrail" "cloudtrail" {
  name = local.name
  s3_bucket_name = var.bucket

  event_selector {
    include_management_events = true

    dynamic "data_resource" {
      for_each = var.selectors
      content {
        type = data_resource.value.type
        values = data_resource.value.values
      }
    }
  }

  tags = {
    terraform = "true"
    environment = terraform.workspace
  }
}
