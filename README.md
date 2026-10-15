# AWS-Event-Driven-Project

Project created to show:

- IaC
- Event driven Architecture
- AWS native Services
- Serverless Patterns
- Lambda functions
- Event Bridge
- SQS
- SNS

## Architecture

1. Flight event
2. Event bridge
3. Lambda function #1
4. SQS Queue
5. Lambda #2
6. SNS Topic
7. Email Notification

## Phases

1. Aws setup
2. Terraform setup
3. SNS notifications
4. SQS queue
5. Notification Lambda
6. SNS integration
7. Event processing lambda
8. Event bridge
9. End to end testing
10. Observability
11. Enhancements

## How to use

How to :

Send Notification (where example message is the flight delay):

```
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" sqs send-message `   
>>   --queue-url "https://sqs.eu-north-1.amazonaws.com/169676386235/flight-events" `
>>   --message-body "Flight BA123 delayed 45 minutes" `
>>   --region eu-north-1
```

View notification:

```
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" sqs receive-message `
  --queue-url "https://sqs.eu-north-1.amazonaws.com/169676386235/flight-events" `
  --region eu-north-1
```

This can also be viewed in my email as it specifies `j.s***@outlook.com`in the `main.tf`file as the endpoint.
