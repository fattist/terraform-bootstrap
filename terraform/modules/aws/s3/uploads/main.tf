variable "acl" { type = string }
variable "cors_allowed_headers" {
    type = list(string)
    default = ["*"]
}
variable "cors_allowed_methods" {
    type = list(string)
    default = ["GET", "POST"]
}
variable "cors_allowed_origins" {
    type = list(string)
    default = ["*"]
}
variable "cors_expose_headers" {
    type = list(string)
    default = []
}
variable "cors_max_age_seconds" {
    type = number
    default = 3000
}
variable "force_destroy" {
    type = bool
    default = false
}
variable "prefix" {
    type = string
    default = "ele-tf"
}
variable "region" { type = string }
variable "service" { type = string }
variable "topic" { type = string }

locals {
    bucket = "${var.prefix}-${var.service}-${terraform.workspace}"
}

# S3 Bucket for Uploads
resource "aws_s3_bucket" "bucket" {
    acl = var.acl
    bucket = local.bucket
    cors_rule {
        allowed_headers = var.cors_allowed_headers
        allowed_methods = var.cors_allowed_methods
        allowed_origins = var.cors_allowed_origins
        expose_headers  = var.cors_expose_headers
        max_age_seconds = var.cors_max_age_seconds
    }
    force_destroy = var.force_destroy
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
output "arn" {
    value = aws_s3_bucket.bucket.arn
}
output "id" {
    value = aws_s3_bucket.bucket.id
}