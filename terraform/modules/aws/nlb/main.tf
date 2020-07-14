variable "internal" {
    type = bool
    default = true
}

variable "load_balancer_type" {
    type = string
    default = "network"
}

variable "name" {
    type = string
}

variable "subnets" {
    type = list(string)
}

resource "aws_lb" "network" {
    name = var.name
    internal = var.internal
    load_balancer_type = var.load_balancer_type
    subnets = var.subnets
}

# EXPORTS
#########

output "arn" {
    value = aws_lb.network.arn
}