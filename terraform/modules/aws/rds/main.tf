variable "allocated_storage" {
    type = number
    default = 100
}
variable "apply_update_immediately" {
    type = bool
    default = false
}
variable "auto_minor_version_upgrade" {
    type = bool
    default = false
}
variable "availability_zones" { type = list(string) }
variable "backup_retention_period" {
    type = number
    default = 7
}
variable "backup_window" {
    type = string
    default = "03:00-06:00"
}
variable "db_password" { type = string }
variable "db_username" { type = string }
variable "db_subnet_group_name" { type = string }
variable "enabled" { type = bool }
variable "enabled_cloudwatch_logs_exports" {
    type = list(string)
    default = ["audit", "error", "slowquery", "postgresql", "upgrade"]
}
variable "engine_version" {
    type = number
    default = 11.5
}
variable "instance_class" { type = string }
variable "kms_key_arn_rds" { type = string }
variable "kms_key_arn_insights" { type = string }
variable "maintenance_window" {
    type = string
    default = "Sun:00:00-Sun:03:00"
}
variable "monitoring_interval" {
    type = number
    default = 15
}
variable "monitoring_role_arn" { type = string }
variable "name" { type = string }
variable "port" {
    type = number
    default = 5432
}
variable "publicly_accessible" {
    type = bool
    default = false
}
variable "security_groups" { type = list(string) }

locals {
    uuid = uuid()
    multi_az = terraform.workspace == "production" ? true : false
    storage_type = terraform.workspace == "production" ? "io1" : "gp2"
}

resource "aws_db_instance" "database" {
    count = var.enabled ? 1 : 0

    allocated_storage = var.allocated_storage
    engine = "postgres"

    engine_version = var.engine_version
    apply_immediately = var.apply_update_immediately
    auto_minor_version_upgrade = var.auto_minor_version_upgrade

    port = var.port
    identifier = var.name

    instance_class = var.instance_class
    storage_encrypted = true
    storage_type = local.storage_type

    kms_key_id = var.kms_key_arn_rds
    final_snapshot_identifier = "${var.name}-${local.uuid}"
    copy_tags_to_snapshot = true

    name = var.name
    password = var.db_password
    username = var.db_username

    availability_zone = var.availability_zones[0]
    multi_az = local.multi_az

    backup_retention_period = var.backup_retention_period
    backup_window = var.backup_window
    maintenance_window = var.maintenance_window
    publicly_accessible = var.maintenance_window

    db_subnet_group_name = var.db_subnet_group_name
    vpc_security_group_ids = var.security_groups

    monitoring_role_arn = var.monitoring_role_arn
    monitoring_interval = var.monitoring_interval
    enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

    performance_insights_enabled = true
    performance_insights_kms_key_id = var.kms_key_arn_insights

    lifecycle {
        prevent_destroy = true
        ignore_changes = [identifier, final_snapshot_identifier, password]
    }

    tags = {
        terraform = "true"
        environment = terraform.workspace
    }
}

#  EXPORTS
output "endpoint" {
    value = length(aws_db_instance.database) > 0 ? aws_db_instance.database[0].endpoint : null
}

output "id" {
    value = length(aws_db_instance.database) > 0 ? aws_db_instance.database[0].id : null
}

output "table_name" {
    value = var.name
}