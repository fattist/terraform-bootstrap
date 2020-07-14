variable "domain" { type = string }
variable "records" { type = list(string) }

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
    name = "${terraform.workspace}.${var.domain}"
    type = var.type
    ttl = var.ttl
    records = var.records
}