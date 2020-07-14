variable "availability_zones" { type = list(string) }
variable "db_password" { type = string }
variable "db_username" { type = string }
variable "enabled" {
    type = bool
    default = true
}
variable "instance_class" { type = string }
variable "name" { type = string }
variable "opsgenie_sns_arn" { type = string }
variable "security_groups" { type = list }
variable "short_env" { type = string }
variable "subnets" { type = list(string) }

locals {
    max_connections = {
        development = 612
        production = 1224
        staging = 612
        test = 612
    }
    name = "${var.name}-${terraform.workspace}"
}

resource "aws_kms_key" "rds" {
    description = local.name

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

resource "aws_kms_key" "insights" {
    description = "insights-${local.name}"

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

module "iam" {
    source = "../../../modules/aws/iam/rds"
    name = local.name
    short_env = var.short_env
}

module "subnet" {
    source = "../../../modules/aws/vpc/subnets/rds"
    name = var.name
    short_env = var.short_env
    subnets = var.subnets
}

module "rds" {
    source = "../../../modules/aws/rds"
    availability_zones = var.availability_zones
    db_password = var.db_password
    db_username = var.db_username
    db_subnet_group_name = module.subnet.name
    enabled = var.enabled
    instance_class = var.instance_class
    kms_key_arn_rds = aws_kms_key.rds.arn
    kms_key_arn_insights = aws_kms_key.insights.arn
    monitoring_role_arn = module.iam.arn
    name = local.name
    security_groups = var.security_groups
}

module "alarms" {
    source = "../../../modules/aws/cloudwatch/alarms"
    alarms = var.enabled ? [{
        alarm_actions = [var.opsgenie_sns_arn]
        alarm_name = local.name
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = 2
        metric_name = "DatabaseConnections"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Maximum"
        threshold = local.max_connections[terraform.workspace]

        dimension = {
            key = "TableName"
            value = module.rds.table_name
        }
    },
    {
        alarm_actions = [var.opsgenie_sns_arn]
        alarm_name = local.name
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = 2
        metric_name = "FreeableMemory"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Maximum"
        threshold = 4096

        dimension = {
            key = "TableName"
            value = module.rds.table_name
        }
    },
    {
        alarm_actions = [var.opsgenie_sns_arn]
        alarm_name = local.name
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = 2
        metric_name = "FreeStorageSpace"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Maximum"
        threshold = 87040

        dimension = {
            key = "TableName"
            value = module.rds.table_name
        }
    }] : []
}