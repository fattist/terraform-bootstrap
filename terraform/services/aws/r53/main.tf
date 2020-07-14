variable "domain" { type = string }
variable "dns" { type = string }
variable "service" { type = string }
variable "zone_id" { type = string }

module "subdomain" {
    source = "../../../modules/aws/r53/record"
    domain = var.domain
    dns = var.dns
    service = var.service
    zone_id = var.zone_id
}