variable "bucket" { type = string }
variable "domain" { type = string }
variable "enable_cross_zone_load_balancing" {
    type = bool
    default = true
}
variable "enable_deletion_protection" {
    type = bool
    default = true
}
variable "health_check" {
  type = object({
        healthy_threshold = number
        unhealthy_threshold = number
        interval = number
        path = string
        port = number
        protocol = string
        timeout = number
        matcher = string
  })
  default = {
        healthy_threshold = 3
        unhealthy_threshold = 5
        interval = 60
        path = "/actuator/health"
        port = 8080
        protocol = "HTTP"
        timeout = 30
        matcher = "200-299"
  }
}
variable "internal" {
    type = bool
    default = false
}
variable "listener_port" {
    type = number
    default = 443
}
variable "listener_protocol" {
    type = string
    default = "HTTPS"
}
variable "name" { type = string }
variable "port" { type = number }
variable "security_groups" { type = list(string) }
variable "service" { type = string }
variable "subnets" { type = list(string) }
variable "target_group_protocol" {
    type = string
    default = "HTTP"
}
variable "target_type" {
    type = string
    default = "ip"
}
variable "vpc_id" { type = string }
variable "zone_id" { type = string }

module "acm" {
  source = "../../../modules/aws/acm"
  domain_name = "*.${var.service}.${var.domain}"
  zone_id = var.zone_id
}

module "subdomain" {
    source = "../../../modules/aws/r53/record"
    alb_dns = aws_alb.alb.dns_name
    domain = var.domain
    service = var.service
    zone_id = var.zone_id
}

resource "aws_alb" "alb" {
    name = var.name
    enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
    enable_deletion_protection = var.enable_deletion_protection
    internal = var.internal
    subnets = var.subnets
    security_groups = var.security_groups

    access_logs {
        bucket  = var.bucket
        prefix  = var.name
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

resource "aws_alb_target_group" "target" {
    name = var.name
    port = var.port
    protocol = var.target_group_protocol
    vpc_id = var.vpc_id
    target_type = var.target_type

    health_check {
        healthy_threshold = var.health_check.healthy_threshold
        unhealthy_threshold = var.health_check.unhealthy_threshold
        interval = var.health_check.interval
        path = var.health_check.path
        port = var.health_check.port
        protocol = var.health_check.protocol
        timeout = var.health_check.timeout
        matcher = var.health_check.matcher
    }

    lifecycle {
        prevent_destroy = true
    }

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }

    depends_on = [aws_alb.alb]
}


resource "aws_alb_listener" "https" {
    load_balancer_arn = aws_alb.alb.id
    port = var.listener_port
    protocol = var.listener_protocol

    certificate_arn = module.acm.certificate_arn
    ssl_policy = "ELBSecurityPolicy-2016-08"

    default_action {
        target_group_arn = aws_alb_target_group.target.id
        type = "forward"
    }

    lifecycle {
        prevent_destroy = true
    }
}

# EXPORTS
#########
output "arn" {
  value = aws_alb.alb.arn
}

output "target_group_arn" {
    value = aws_alb_target_group.target.arn
}