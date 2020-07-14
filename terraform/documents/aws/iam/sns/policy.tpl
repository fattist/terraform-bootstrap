{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${topic}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${source}"}
        }
    }]
}