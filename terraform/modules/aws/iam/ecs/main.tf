data "aws_iam_role" "ecsServiceRole" {
  name = "ecsServiceRole"
}

# EXPORTS
#########
output "arn" {
    value = data.aws_iam_role.ecsServiceRole.arn
}