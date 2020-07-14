variable "domain_name" { type = string }
variable "ttl" {
    type = number
    default = 60
}
variable "validation_method" {
    type = string
    default = "DNS"
}
variable "zone_id" { type = string }

resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  validation_method = var.validation_method
}

resource "aws_route53_record" "record" {
  name = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl = var.ttl
}

resource "aws_acm_certificate_validation" "ssl" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.record.fqdn]
}

# EXPORTS
output "certificate_arn" {
  value = aws_acm_certificate_validation.ssl.certificate_arn
}