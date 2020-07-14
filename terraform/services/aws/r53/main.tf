variable "domain" {
    type = string
}

variable "profile" {
    type = string
}

variable "service" {
    type = string
}

provider "aws" {
  alias = "global"
  version = "~> 2.57.0"
  profile = var.profile
  region = "us-east-1"
}

data "aws_route53_zone" "domain" {
  name = var.domain
}

data "aws_api_gateway_rest_api" "api" {
    name = "${terraform.workspace}-${var.service}"
}

module "acm-wildcard" {
    source = "../../../modules/aws/acm"
    domain = "*.${var.domain}"
    zone_id = data.aws_route53_zone.domain.zone_id

    providers = {
        aws = aws.global
    }
}

resource "aws_api_gateway_domain_name" "tld" {
    certificate_arn = module.acm-wildcard.certificate_arn
    domain_name = "${terraform.workspace}.${var.domain}"
}

module "dns" {
    source = "../../../modules/aws/r53/alias"
    domain = var.domain
    zone_id = data.aws_route53_zone.domain.zone_id
    aliases = [{
        evaluate_target_health = true
        name = aws_api_gateway_domain_name.tld.cloudfront_domain_name
        zone_id = aws_api_gateway_domain_name.tld.cloudfront_zone_id
    }]
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
    api_id = data.aws_api_gateway_rest_api.api.id
    stage_name = terraform.workspace
    domain_name = aws_api_gateway_domain_name.tld.domain_name
}