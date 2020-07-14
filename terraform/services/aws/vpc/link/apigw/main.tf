variable "service" {
    type = string
}

variable "subnets" {
    type = list(string)
}

locals {
    name = "${terraform.workspace}-${var.service}"
}

module "nlb" {
    source = "../../../../../modules/aws/nlb"
    name = local.name
    subnets = var.subnets
}

resource "aws_api_gateway_vpc_link" "link" {
    name = local.name
    target_arns = [module.nlb.arn]
}

# EXPORTS
#########

output "id" {
    value = aws_api_gateway_vpc_link.link.id
}