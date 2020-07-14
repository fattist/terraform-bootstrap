variable "bucket-input" { type = string }
variable "bucket-output" { type = string }
variable "name" { type = string }
variable "short_env" { type = string }
variable "sns" { type = string }
variable "sns-create-voice" { type = string}


resource "aws_iam_role" "role" {
    name = "${var.short_env}-${var.name}"
    assume_role_policy = file("${path.root}/documents/aws/iam/transcode/role.json") 
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
    policy = templatefile("${path.root}/documents/aws/iam/transcode/policy.tpl", {
        bucket-input = var.bucket-input
        bucket-output = var.bucket-output
        sns = var.sns
        sns-create-voice = var.sns-create-voice
    })
    role = aws_iam_role.role.id
    depends_on = [aws_iam_role.role]
}

# EXPORTS
#########
output "arn" {
    value = aws_iam_role.role.arn
}