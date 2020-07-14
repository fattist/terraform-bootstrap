{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "1",
        "Effect": "Allow",
        "Action": [
          "s3:Put*",
          "s3:ListBucket",
          "s3:*MultipartUpload*",
          "s3:Get*"
        ],
        "Resource": [
            "${bucket-input}",
            "${bucket-input}/*",
            "${bucket-output}",
            "${bucket-output}/*"
        ]
      },
      {
        "Sid": "2",
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": [
          "${sns}",
          "${sns-create-voice}"
        ]
      },
      {
        "Sid": "3",
        "Effect": "Deny",
        "Action": [
          "sns:*Remove*",
          "sns:*Delete*",
          "sns:*Permission*"
        ],
        "Resource": [
          "${sns}",
          "${sns-create-voice}"
        ]
      },
      {
        "Sid": "4",
        "Effect": "Deny",
        "Action": [
          "s3:*Delete*",
          "s3:*Policy*"
        ],
        "Resource": [
            "${bucket-input}",
            "${bucket-input}/*",
            "${bucket-output}",
            "${bucket-output}/*"
        ]
      }
    ]
  }