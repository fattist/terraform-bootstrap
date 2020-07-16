variable "alarms" {
    type = list(object({
        alarm_actions = list(string)
        alarm_name = string
        comparison_operator = string
        dimension = object({})
        evaluation_periods = number
        metric_name = string
        namespace = string
        period = number
        statistic = string
        threshold = number
    }))
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
    count = length(var.alarms)

    alarm_actions = var.alarms[count.index].alarm_actions
    alarm_name = var.alarms[count.index].alarm_name
    comparison_operator = var.alarms[count.index].comparison_operator
    dimensions = var.alarms[count.index].dimension
    evaluation_periods = var.alarms[count.index].evaluation_periods
    metric_name = var.alarms[count.index].metric_name
    namespace = var.alarms[count.index].namespace
    period = var.alarms[count.index].period
    statistic = var.alarms[count.index].statistic
    threshold = var.alarms[count.index].threshold
}