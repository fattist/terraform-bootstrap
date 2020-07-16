variable "account_arn" { type = string }
variable "region" { type = string }

locals {
    name = "${terraform.workspace}-lambda"
}

resource "aws_iam_role" "role" {
    name = "${local.name}-role"
    assume_role_policy = file("${path.module}/tpl/role.json")

    lifecycle {
        ignore_changes = [force_detach_policies]
    }
}

resource "aws_iam_role_policy" "policy" {
    name = "${local.name}-policy"
    role = aws_iam_role.role.name
    policy = templatefile("${path.module}/tpl/policy.tpl", {
        account_arn = var.account_arn
        region = var.region
    })
}

# EXPORTS

output "arn" {
    value = aws_iam_role.role.arn
}