# AWS Account Information
data "aws_caller_identity" "current" {}

# data "aws_region" "current" {}

# SNS Topic
resource "aws_sns_topic" "flight_notifications" {
  name              = "flight-notifications"
  kms_master_key_id = "alias/aws/sns"
}

# Email Subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.flight_notifications.arn
  protocol  = "email"
  endpoint  = "j.shanley.pratt@outlook.com"
}

# SQS Queue
resource "aws_sqs_queue" "flight_events" {
  name = "flight-events"

  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.flight_dlq.arn
    maxReceiveCount     = 3
  })
}

##################################################
# LAMBDA IAM ROLE
##################################################

resource "aws_iam_role" "lambda_role" {
  name = "flight_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

##################################################
# CLOUDWATCH LOGGING PERMISSIONS
##################################################

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##################################################
# CUSTOM SNS + SQS POLICY
##################################################

resource "aws_iam_policy" "lambda_sns_sqs_policy" {

  name = "LambdaSNSSQSPolicy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "sns:Publish"
        ]

        Effect = "Allow"

        Resource = [
          aws_sns_topic.flight_notifications.arn
        ]
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Effect = "Allow"

        Resource = [
          aws_sqs_queue.flight_events.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_sqs_policy.arn
}

##################################################
# PACKAGE LAMBDA CODE
##################################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/processor/index.py"
  output_path = "../lambda/processor.zip"
}

##################################################
# LAMBDA FUNCTION
##################################################

resource "aws_lambda_function" "processor" {

  function_name = "flight-event-processor"
  tracing_config {
    mode = "Active"
  }

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "python3.13"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.flight_notifications.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_custom
  ]

}

##################################################
# SQS -> LAMBDA TRIGGER
##################################################

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {

  event_source_arn = aws_sqs_queue.flight_events.arn
  function_name    = aws_lambda_function.processor.arn

  batch_size = 1
}

# DLQ for failed messages in SQS
resource "aws_sqs_queue" "flight_dlq" {
  name                    = "flight-events-dlq"
  sqs_managed_sse_enabled = true
}