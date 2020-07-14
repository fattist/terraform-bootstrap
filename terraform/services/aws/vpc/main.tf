variable "short_env" { type = string }
variable "apigw_endpoint_security_group_ids" {
  type = list(string)
}
variable "endpoint_security_group_ids" {
  type = list(string)
}

# VPC
#####
module "vpc" {
  source = "../../../modules/aws/vpc"
  apigw_endpoint_security_group_ids = var.apigw_endpoint_security_group_ids
  endpoint_security_group_ids = var.endpoint_security_group_ids
}

# CW
####
resource "aws_cloudwatch_log_group" "log_group" {
  name = "vpc-${terraform.workspace}"
}

# IAM
#####
module "iam" {
  source = "../../../modules/aws/iam/flowlog"
  name = "flowlog"
  short_env = var.short_env
}

# FLG
#####
resource "aws_flow_log" "flow_log" {
  traffic_type = "ALL"

  iam_role_arn = module.iam.arn
  log_destination = aws_cloudwatch_log_group.log_group.arn

  vpc_id = module.vpc.vpc_id
}

# EXPORTS
#########
output "availability_zones" {
  value = module.vpc.availability_zones
}

output "flg_id" {
  value = aws_cloudwatch_log_group.log_group.id
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "intra_subnets_cidr_blocks" {
  value = module.vpc.intra_subnets_cidr_blocks
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpn_private_ip" {
  value = module.vpc.vpn_private_ip
}

output "vpn_public_ip" {
  value = module.vpc.vpn_public_ip
}