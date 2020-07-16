variable "account_arn" { type = string }
variable "region" { type = string }

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
        min = 1000
        max = 2500
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
        min = 1500
        max = 3500
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