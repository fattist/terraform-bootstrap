variable "acl" { type = string }
variable "region" { type = string }
variable "service" { type = string }

locals {
    bucket-output = "${var.service}-transcoded"
}

module "iam" {
    source = "../../../../modules/aws/iam/transcode"
    bucket-input = module.s3-input.arn
    bucket-output = module.s3-output.arn
    name = var.service
    short_env = "${terraform.workspace}-transcode-iam"
    sns = module.sns.arn
    sns-create-voice = module.sns-create-voice.arn
}

module "sns" {
    source = "../../../../modules/aws/sns"
    endpoint =  module.sqs.arn
    policy_file = templatefile("${path.root}/documents/aws/iam/sns/policy.tpl", {
        source = module.s3-input.arn
        topic = "${var.service}-sns-${terraform.workspace}"
    })
    protocol = "sqs"
    topic = "${var.service}-sns"
}

module "sqs" {
    source = "../../../../modules/aws/sqs"
    policy_file = templatefile("${path.root}/documents/aws/iam/sqs/s3/policy.tpl", {
        sns = module.sns.arn
        topic = "${var.service}-sns-${terraform.workspace}"
    })
    topic = "${var.service}-sns"
}

module "s3-input" {
    source = "../../../../modules/aws/s3/uploads"
    acl = var.acl
    region = var.region
    service = var.service
    topic = module.sns.arn
}

module "s3-output" {
    source = "../../../../modules/aws/s3/uploads"
    acl = var.acl
    region = var.region
    service = local.bucket-output
    topic = module.sns-create-voice.arn
}

# S3 Bucket Notification for .raw file upload
resource "aws_s3_bucket_notification" "notification" {
    bucket = module.s3-input.id
    topic {
        topic_arn = module.sns.arn
        events = ["s3:ObjectCreated:Put"]
        filter_suffix = ".raw"
    }
}

# S3 Bucket Notification for .wav file upload
resource "aws_s3_bucket_notification" "notification_wav" {
    bucket = module.s3-output.id
    topic {
        topic_arn = module.sns-create-voice.arn
        events = ["s3:ObjectCreated:Put"]
        filter_suffix = ".wav"
    }
}

module "transcode" {
    source = "../../../../modules/aws/transcode/audio"
    input_bucket = module.s3-input.id
    name = var.service
    output_bucket = module.s3-output.id
    role = module.iam.arn
}

module "sns-create-voice" {
    source = "../../../../modules/aws/sns"
    endpoint =  module.sqs-create-voice.arn
    policy_file = templatefile("${path.root}/documents/aws/iam/sns/policy.tpl", {
        source = module.s3-output.arn
        topic = "${var.service}-sns-create-voice-${terraform.workspace}"
    })
    protocol = "sqs"
    topic = "${var.service}-sns-create-voice"
}

module "sqs-deadletter-create-voice" {
    source = "../../../../modules/aws/sqs/dead-letter-queue"
    delay_seconds = 90
    max_message_size = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    topic = "${var.service}-sqs-deadletter-create-voice"
}

module "sqs-create-voice" {
    source = "../../../../modules/aws/sqs"
    policy_file = templatefile("${path.root}/documents/aws/iam/sqs/s3/policy.tpl", {
        sns = module.sns-create-voice.arn
        topic = "${var.service}-sns-create-voice-${terraform.workspace}"
    })
    redrive_policy = jsonencode({
        deadLetterTargetArn = module.sqs-deadletter-create-voice.arn
        maxReceiveCount     = 4
    })
    topic = "${var.service}-sns-create-voice"
    
}

module "sns-create-voice-clip" {
    source = "../../../../modules/aws/sns"
    endpoint =  module.sqs-create-voice-clip.arn
    policy_file = templatefile("${path.root}/documents/aws/iam/sns/policy.tpl", {
        source = "arn:aws:states:us-west-2:827235528759:stateMachine:createVoiceClipSM-dev"
        topic = "${var.service}-sns-${terraform.workspace}"
    })
    protocol = "sqs"
    topic = "${var.service}-sns-create-voice-clip"
}

module "sqs-deadletter-create-voice-clip" {
    source = "../../../../modules/aws/sqs/dead-letter-queue"
    delay_seconds = 90
    max_message_size = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    topic = "${var.service}-sqs-deadletter-create-voice-clip"
}

module "sqs-create-voice-clip" {
    source = "../../../../modules/aws/sqs"
    policy_file = templatefile("${path.root}/documents/aws/iam/sqs/s3/policy.tpl", {
        sns = module.sns-create-voice-clip.arn
        topic = "${var.service}-sns-create-voice-clip-${terraform.workspace}"
    })
    redrive_policy = jsonencode({
        deadLetterTargetArn = module.sqs-deadletter-create-voice-clip.arn
        maxReceiveCount     = 4
    })
    topic = "${var.service}-sns-create-voice-clip"
    
}

# EXPORTS
output "arn-input" {
    value = module.s3-input.arn
}

output "arn-output" {
    value = module.s3-output.arn
}