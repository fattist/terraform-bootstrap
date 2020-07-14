variable "alb_security_groups" { type = list(string) }
variable "bucket" { type = string }
variable "container_security_groups" { type = list(string) }
variable "cpu" {
    type = number
    default = 512
}
variable "domain" { type = string }
variable "memory" {
    type = number
    default = 1024
}
variable "port" {
    type = number
    default = 8080
}
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "region" { type = string }
variable "service" { type = string }
variable "vpc_id" { type = string }
variable "zone_id" { type = string }

locals {
    name = "${var.service}-service-${terraform.workspace}"
}

module "cluster" {
    source = "../../../modules/aws/ecs/cluster"
    service = var.service
}

module "iam" {
    source = "../../../modules/aws/iam/ecs"
}

module "repository" {
    source = "../../../modules/aws/ecr"
    service = var.service
}

module "definition" {
    source = "../../../modules/aws/ecs/definition"
    execution_role_arn = module.iam.arn
    cpu = var.cpu
    image = module.repository.url
    memory = var.memory
    name = local.name
    port = var.port
    region = var.region
}

module "alb" {
    source = "../alb"
    bucket = var.bucket
    domain = var.domain
    name = local.name
    port = var.port
    security_groups = var.alb_security_groups
    service = var.service
    subnets = var.public_subnets
    vpc_id = var.vpc_id
    zone_id = var.zone_id
}

module "service" {
    source = "../../../modules/aws/ecs/service"
    cluster = module.cluster.id
    data_revision = module.definition.data_revision
    definition_revision = module.definition.definition_revision
    desired_count = 0
    family = module.definition.family
    name = local.name
    port = var.port
    container_security_groups = var.container_security_groups
    subnets = var.private_subnets
    target_group_arn = module.alb.target_group_arn
}

# EXPORTS
#########
output "iam_service_role_arn" {
    value = module.iam.arn
}