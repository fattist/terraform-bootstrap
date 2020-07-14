variable "name" { type = string }
variable "short_env" { type = string }

resource "aws_iam_role" "role" {
    name = "${var.short_env}-${var.name}"

    assume_role_policy = file("${path.cwd}/documents/aws/iam/flowlog/role.json")

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

resource "aws_iam_role_policy" "policy" {
    name = "${var.short_env}-${var.name}"
    role = aws_iam_role.role.id

    policy = file("${path.cwd}/documents/aws/iam/flowlog/policy.json")
}

# EXPORTS
#########
output "arn" {
    value = aws_iam_role.role.arn
}