variable "domain" { type = string }
variable "dns" { type = string }
variable "service" { type = string }
variable "ttl" {
    type = number
    default = 300
}
variable "type" { 
    type = string
    default = "CNAME"
}
variable "zone_id" { type = string }

resource "aws_route53_record" "record" {
    zone_id = var.zone_id
    name = "${terraform.workspace}.${var.service}.${var.domain}"
    type = var.type
    ttl = var.ttl
    records = [var.dns]
}