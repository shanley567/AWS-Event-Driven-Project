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

# Adding the SQS queue resource to the Terraform configuration
resource "aws_sqs_queue" "flight_events" {
  name = "flight-events"
}

### LAMBDA FUNCTION SETUP ###
# 1. IAM Role: The "Identity" the Lambda assumes
resource "aws_iam_role" "lambda_role" {
  name = "flight_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2. Permissions: Allow Lambda to write logs and talk to SNS/SQS
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_sns_sqs_policy" {
  name = "LambdaSNSSQSPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sns:Publish"]
        Effect = "Allow"
        Resource = [aws_sns_topic.flight_notifications.arn]
      },
      {
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Effect = "Allow"
        Resource = [aws_sqs_queue.flight_events.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_sqs_policy.arn
}

# 3. The Lambda Function itself
resource "aws_lambda_function" "notifier" {
  filename      = "../lambda/notifier/index.zip" # Make sure you zip the code!
  function_name = "flight-notifier"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.flight_notifications.arn
    }
  }
}

# 4. The Trigger: This tells AWS "Whenever SQS gets a message, run this Lambda"
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.flight_events.arn
  function_name    = aws_lambda_function.notifier.arn
}