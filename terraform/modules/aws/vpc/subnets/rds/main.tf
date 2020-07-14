variable "name" { type = string }
variable "short_env" { type = string }
variable "subnets" { type = list(string) }

resource "aws_db_subnet_group" "group" {
    name = "${var.short_env}-${var.name}"
    subnet_ids = var.subnets

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

# OUTPUT
output "name" {
    value = aws_db_subnet_group.group.name
}
