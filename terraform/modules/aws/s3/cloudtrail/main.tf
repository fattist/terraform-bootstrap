variable "acl" { type = string }
variable "force_destroy" {
    type = bool
    default = false
}
variable "prefix" {
    type = string
    default = "terraform"
}
variable "region" { type = string }
variable "service" { type = string }

locals {
    bucket = "${var.prefix}-${var.service}-${terraform.workspace}"
}

# S3 Bucket for Uploads
resource "aws_s3_bucket" "bucket" {
    acl = var.acl
    bucket = local.bucket
    force_destroy = var.force_destroy
    policy = templatefile("${path.root}/documents/aws/iam/s3/cloudtrail/policy.tpl", {
        bucket = local.bucket
    })
    region = var.region
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "aws:kms"
            }
        }
    }
    versioning {
        enabled = true
    }
}

# EXPORTS
output "id" {
    value = aws_s3_bucket.bucket.id
}