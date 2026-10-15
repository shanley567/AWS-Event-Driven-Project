# This file is used to configure the AWS provider for Terraform.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Adding the SNS topic resource to the Terraform configuration
resource "aws_sns_topic" "flight_notifications" {
  name = "flight-notifications"
}

# Adding the SNS topic subscription resource to the Terraform configuration
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.flight_notifications.arn
  protocol  = "email"
  endpoint  = "j.shanley.pratt@outlook.com"
}