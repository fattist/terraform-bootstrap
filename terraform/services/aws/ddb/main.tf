variable "account_arn" { type = string }
variable "region" { type = string }
variable "alarm_sns_arn" { type = string }

locals {
    read = {
        min = 1000
        max = 2500
    }
    write = {
        min = 1500
        max = 3500
    }
}

data "aws_iam_role" "DynamoDBAutoscaleRole" {
    name = "AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"
}

module "iam" {
    source = "../../../modules/aws/iam/lambda/ddb"
    account_arn = var.account_arn
    region = var.region
}

module "table" {
    source = "../../../modules/aws/ddb"
    name = "users"
    hash = {
        name = "sub"
    }
    stream = {
        enabled = true
        view_type = "NEW_IMAGE"
    }
    attr = [{
        name = "sub"
        type = "S"
    },{
        name = "email"
        type = "S"
    }]
    gsi = [{
        name = "emailIndex"
        hash_key = "email"
        write_capacity = 5
        read_capacity = 5
        projection_type = "ALL"
        non_key_attributes = [""]
    }]
}

module "autoscaling-read" {
    source = "../../../modules/aws/appautoscaling"
    capacity = {
        min = local.read.min
        max = local.read.max
    }
    policy_type = "TargetTrackingScaling"
    resource_id = "table/${module.table.name}"
    role_arn = data.aws_iam_role.DynamoDBAutoscaleRole.arn
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace = "dynamodb"

    config = [{
        target_value = 70
        predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }]
}

module "autoscaling-write" {
    source = "../../../modules/aws/appautoscaling"
    capacity = {
        min = local.write.min
        max = local.write.max
    }
    policy_type = "TargetTrackingScaling"
    resource_id = "table/${module.table.name}"
    role_arn = data.aws_iam_role.DynamoDBAutoscaleRole.arn
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace = "dynamodb"

    config = [{
        target_value = 70
        predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }]
}

module "alarms" {
    source = "../../../modules/aws/cloudwatch/alarms"
    alarms = [{
        alarm_actions = [var.alarm_sns_arn]
        alarm_name = "read"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = 2
        metric_name = "ConsumedReadCapacityUnits"
        namespace = "AWS/DynamoDB"
        period = 60
        statistic = "Maximum"
        threshold = local.read.max

        dimension = {
            TableName = module.table.name
        }
    }, {
        alarm_actions = [var.alarm_sns_arn]
        alarm_name = "write"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = 2
        metric_name = "ConsumedWriteCapacityUnits"
        namespace = "AWS/DynamoDB"
        period = 60
        statistic = "Maximum"
        threshold = local.write.max
        dimension = {
            TableName = module.table.name
        }
    }]
}