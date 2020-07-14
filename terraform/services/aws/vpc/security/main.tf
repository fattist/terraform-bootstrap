variable "intra_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "vpc_id" { type = string }
variable "vpn_eip" { type = string }

locals {
    alb = {
        development = concat(var.public_subnets, ["${var.vpn_eip}/32"])
        production = concat(var.public_subnets, ["${var.vpn_eip}/32"])
        staging = concat(var.private_subnets, ["${var.vpn_eip}/32"])
        test = concat(var.private_subnets, ["${var.vpn_eip}/32"])
        private = concat(var.private_subnets, ["${var.vpn_eip}/32"])
        public = concat(var.public_subnets, ["${var.vpn_eip}/32"])
    }
    egress = concat(var.intra_subnets, var.private_subnets, var.public_subnets)
    ingress = concat(var.private_subnets, ["${var.vpn_eip}/32"])
}

module "alb" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "ALB services"
    service = "alb"
    vpc_id = var.vpc_id

    incoming = [{
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = local.alb.public
    },{
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = local.alb.public
    }]

    outgoing = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = local.alb.private
    }]
}

module "apigw" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "APIGW services"
    service = "apigw"
    vpc_id = var.vpc_id

    incoming = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }]

    outgoing = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }]
}

module "bastion" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "allow inbound access to bastion"
    service = "${terraform.workspace}-bastion"
    vpc_id = var.vpc_id

    incoming = [{
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }]

    outgoing = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }]
}

module "endpoint" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "Internal services"
    service = "endpoint"
    vpc_id = var.vpc_id

    incoming = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = local.ingress
    }]

    outgoing = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = local.egress
    }]
}

module "ecs" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "ECS services"
    service = "ecs"
    vpc_id = var.vpc_id

    incoming = [{
        protocol = "tcp"
        from_port = 8080
        to_port = 9000
        cidr_blocks = local.alb[terraform.workspace]
    }]

    outgoing = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }]
}

module "openvpn" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "Allow OPENVPN requests to subnet"
    service = "${terraform.workspace}-openvpn"
    vpc_id = "${var.vpc_id}"

    incoming = [{
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 1194
        to_port = 1194
    },{
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 943
        to_port = 943
    },{
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 443
        to_port = 443
    }]

    outgoing = [{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }]
}

module "rds" {
    source = "../../../../modules/aws/vpc/security/group"
    cidr = local.alb[terraform.workspace]
    description = "RDS services"
    service = "rds"
    vpc_id = var.vpc_id

    incoming = [{
        protocol = "tcp"
        from_port = 5432
        to_port = 5432
        cidr_blocks = local.ingress
    }]

    outgoing = [{
        protocol = "tcp"
        from_port = 5432
        to_port = 5432
        cidr_blocks = local.egress
    }]
}

# EXPORTS
#########
output "alb_id" {
    value = module.alb.id
}

output "apigw_id" {
    value = module.apigw.id
}

output "bastion_id" {
    value = module.bastion.id
}

output "ecs_id" {
    value = module.ecs.id    
}

output "endpoint_id" {
    value = module.endpoint.id
}

output "openvpn_id" {
    value = module.openvpn.id
}

output "rds_id" {
    value = module.rds.id
}