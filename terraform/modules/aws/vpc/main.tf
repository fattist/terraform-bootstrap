variable "apigw_endpoint_security_group_ids" {
  type = list(string)
}
variable "endpoint_security_group_ids" {
  type = list(string)
}

# NOTE: 65.534k hosts
variable "cidr" {
  type = object({
    development = string
    test = string
    staging = string
    production = string
  })
  default = {
    development = "172.16.0.0/16"
    test = "172.17.0.0/16"
    staging = "172.18.0.0/16"
    production = "172.19.0.0/16"
  }
}

# NOTE: NAT access
variable "private" {
  type = object({
    development = list(string)
    test = list(string)
    staging = list(string)
    production = list(string)
  })
  default = {
    development = ["172.16.1.0/24","172.16.2.0/24","172.16.3.0/24"]
    test = ["172.17.1.0/24","172.17.2.0/24","172.17.3.0/24"]
    staging = ["172.18.1.0/24","172.18.2.0/24","172.18.3.0/24"]
    production = ["172.19.1.0/24","172.19.2.0/24","172.19.3.0/24"]
  }
}

# NOTE: VPN access
variable "public" {
  type = object({
    development = list(string)
    test = list(string)
    staging = list(string)
    production = list(string)
  })
  default = {
    development = ["172.16.101.0/24","172.16.102.0/24","172.16.103.0/24"]
    test = ["172.17.101.0/24","172.17.102.0/24","172.17.103.0/24"]
    staging = ["172.18.101.0/24","172.18.102.0/24","172.18.103.0/24"]
    production = ["172.19.101.0/24","172.19.102.0/24","172.19.103.0/24"]
  }
}

# NOTE: AWS egress only
variable "intra" {
  type = object({
    development = list(string)
    test = list(string)
    staging = list(string)
    production = list(string)
  })
  default = {
    development = ["172.16.201.0/24","172.16.202.0/24","172.16.203.0/24"]
    test = ["172.17.201.0/24","172.17.202.0/24","172.17.203.0/24"]
    staging = ["172.18.201.0/24","172.18.202.0/24","172.18.203.0/24"]
    production = ["172.19.201.0/24","172.19.202.0/24","172.19.203.0/24"]
  }
}

resource "aws_eip" "nat" {
  count = 3
  vpc = true

  tags = {
    terraform = "true"
    environment = terraform.workspace
  }
}

resource "aws_eip" "vpn" {
  vpc = true

  tags = {
    name = "vpn"
    terraform = "true"
    environment = terraform.workspace
  }
}

data "aws_availability_zones" "zones" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = terraform.workspace
  cidr = var.cidr[terraform.workspace]
  azs = data.aws_availability_zones.zones.names

  enable_nat_gateway = true
  single_nat_gateway = false
  reuse_nat_ips = true
  one_nat_gateway_per_az = false

  external_nat_ip_ids = concat(aws_eip.nat.*.id, [aws_eip.vpn.id])

  enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_dns_support = true

  enable_dhcp_options = true

  enable_apigw_endpoint = true
  apigw_endpoint_security_group_ids = var.apigw_endpoint_security_group_ids

  enable_dynamodb_endpoint = true
  enable_kms_endpoint = true
  kms_endpoint_security_group_ids = var.endpoint_security_group_ids

  enable_s3_endpoint = true
  enable_ssm_endpoint = true
  ssm_endpoint_security_group_ids = var.endpoint_security_group_ids

  private_subnets = var.private[terraform.workspace]
  public_subnets = var.public[terraform.workspace]
  intra_subnets = var.intra[terraform.workspace]

  tags = {
    terraform = "true"
    environment = terraform.workspace
  }
}

# EXPORTS

output "availability_zones" {
  value = module.vpc.azs
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
  value = aws_eip.vpn.private_ip
}

output "vpn_public_ip" {
  value = aws_eip.vpn.public_ip
}