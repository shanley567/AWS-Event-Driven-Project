# This file is used to define the output values for the Terraform configuration.
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.region
}

# Adding the output for the SNS topic
output "sns_topic_arn" {
  value = aws_sns_topic.flight_notifications.arn
}

# Adding the output for the SQS queue
output "sqs_queue_url" {
  value = aws_sqs_queue.flight_events.url
}