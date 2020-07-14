variable "aliases" {
    type = list(object({
        evaluate_target_health = bool
        name = string
        zone_id = string
    }))
}
variable "domain" { type = string }

variable "type" { 
    type = string
    default = "A"
}

variable "zone_id" { type = string }

resource "aws_route53_record" "record" {
    zone_id = var.zone_id
    name = "${terraform.workspace}.${var.domain}"
    type = var.type

    dynamic "alias"     {
        for_each = var.aliases
        content {
            evaluate_target_health = alias.value.evaluate_target_health
            name = alias.value.name
            zone_id = alias.value.zone_id
        }
    }
}