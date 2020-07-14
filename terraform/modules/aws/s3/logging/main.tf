variable "account_arn" { type = string }
variable "acl" { type = string }
variable "force_destroy" {
    type = bool
    default = false
}
variable "prefix" {
    type = string
    default = "mhd-tf"
}
variable "region" { type = string }
variable "service" { type = string }
variable "vpc_id" { type = string }

locals {
    bucket = "${var.prefix}-${var.service}-${terraform.workspace}"
}

resource "aws_s3_bucket" "bucket" {
    bucket = local.bucket
    acl = var.acl
    force_destroy = var.force_destroy

    policy = templatefile("${path.root}/documents/aws/iam/s3/logging/policy.tpl", {
        account = var.account_arn
        bucket = local.bucket
        region = var.region
    })

    lifecycle {
        prevent_destroy = true
    }

    lifecycle_rule {
        id = "${local.bucket}-glacier"
        enabled = true

        transition {
            days = 365
            storage_class = "GLACIER"
        }

        expiration {
            days = 395
        }

        tags = {
            terraform = "true"
            environment = terraform.workspace
            rule = "glacier"
        }
    }
}

# EXPORTS
output "id" {
    value = aws_s3_bucket.bucket.id
}