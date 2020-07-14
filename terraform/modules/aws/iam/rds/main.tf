variable "name" { type = string }
variable "short_env" { type = string }

resource "aws_iam_role" "role" {
    name = "${var.short_env}-${var.name}"
    assume_role_policy = file("${path.cwd}/documents/aws/iam/rds/role.json")

    lifecycle {
        ignore_changes = [force_detach_policies]
    }

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

resource "aws_iam_role_policy" "policy" {
    name = "${var.short_env}-${var.name}"
    role = aws_iam_role.role.id

    policy = file("${path.cwd}/documents/aws/iam/rds/policy.json")
    depends_on = [aws_iam_role.role]
}

# EXPORTS
#########
output "arn" {
    value = aws_iam_role.role.arn
}