variable "domain" {
  type = string
  default = "mhd.fatt.dev"
}

provider "aws" {
  version = "~> 2.57.0"
  profile = var.PROFILE
  region = var.REGION
}

terraform {
  backend "s3" {
    encrypt = "true"
  }
}

data "aws_caller_identity" "current" {}

#  VPC - NETWORKING
##################
module "networking" {
  source = "./services/aws/vpc"
  short_env = var.SHORT_ENV[terraform.workspace]
  apigw_endpoint_security_group_ids = [module.security.apigw_id]
  endpoint_security_group_ids = [module.security.endpoint_id]
}

# VPC - SECURITY
# TODO: replace vpn_public_ip with vpn_private_ip when VPN server is placed
################
module "security" {
  source = "./services/aws/vpc/security"
  intra_subnets = module.networking.intra_subnets_cidr_blocks
  private_subnets = module.networking.private_subnets_cidr_blocks
  public_subnets = module.networking.public_subnets_cidr_blocks
  vpc_id = module.networking.vpc_id
  vpn_eip = module.networking.vpn_public_ip
}

# VPC - APIGW LINK
##################
module "apigw-link" {
  source = "./services/aws/vpc/link/apigw"
  service = "serverless-link"
  subnets = module.networking.private_subnets
}

# DDB
#####
module "ddb" {
  source = "./services/aws/ddb"
  account_arn = data.aws_caller_identity.current.account_id
  region = var.REGION
  # sns_arn = module.opsgenie.sns_arn
}

# R53
#####
module "dns-records" {
  source = "./services/aws/r53"
  domain = "mhd.fatt.dev"
  profile = var.PROFILE
  service = "mhd"
}

# S3
####
module "s3-logging" {
  source = "./modules/aws/s3/logging"
  account_arn = data.aws_caller_identity.current.account_id
  acl = "log-delivery-write"
  region = var.REGION
  service = "logging"
  vpc_id = module.networking.vpc_id
}

# SSM
#####
module "ssm-vpc-id" {
  source = "./modules/aws/ssm/secure/string"
  service = "vpc/id"
  value = module.networking.vpc_id
}

module "ssm-vpc-link" {
  source = "./modules/aws/ssm/secure/string"
  service = "vpc/apigw/link"
  value = module.apigw-link.id
}

module "ssm-subnet-intra" {
  source = "./modules/aws/ssm/string/list"
  service = "vpc/subnet/intra"
  value = module.networking.intra_subnets
}

module "ssm-subnet-private" {
  source = "./modules/aws/ssm/string/list"
  service = "vpc/subnet/private"
  value = module.networking.private_subnets
}

module "ssm-subnet-public" {
  source = "./modules/aws/ssm/string/list"
  service = "vpc/subnet/public"
  value = module.networking.public_subnets
}

module "ssm-sls-apigw-sg" {
  source = "./modules/aws/ssm/string"
  service = "vpc/sg/apigw"
  value = module.security.apigw_id
}

# MONITORING
############

module "opsgenie" {
  source = "./services/opsgenie"
  endpoint = var.OPSGENIE_SRE_ENDPOINT
}