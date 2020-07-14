{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "arn:aws:sqs:*:*:${topic}",
        "Condition":{
            "ArnEquals":{
                "aws:SourceArn":"${sns}"
            }
        }
    }]
}