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

```PowerShell
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" sqs send-message `   
>>   --queue-url "https://sqs.eu-north-1.amazonaws.com/169676386235/flight-events" `
>>   --message-body "Flight BA123 delayed 45 minutes" `
>>   --region eu-north-1
```

View notification:

```PowerShell
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" sqs receive-message `
  --queue-url "https://sqs.eu-north-1.amazonaws.com/169676386235/flight-events" `
  --region eu-north-1
```

This can also be viewed in my email as it specifies `j.s***@outlook.com`in the `main.tf`file as the endpoint.

Co-Pilot Setup:

This is an excellent interview-prep project because it demonstrates:

* AWS fundamentals
* Event-driven architecture
* Serverless
* Infrastructure as Code
* Terraform
* Lambda
* EventBridge
* SQS
* SNS

All technologies directly mentioned or closely related to the AeroCloud stack.

# Final Architecture

Plain Text

Flight Delay Event

        |

        v

EventBridge

        |

        v

Lambda #1

(Process Flight Event)

        |

        v

SQS Queue

        |

        v

Lambda #2

(Notification Handler)

        |

        v

SNS Topic

        |

        v

Email Notification

Example:

JSON

{

  "flightNumber": "BA123",

  "status": "DELAYED",

  "delayMinutes": 45

}

---

# Phase 1: AWS Setup

Goal:

Create an AWS environment suitable for development.

Steps:

1. Create AWS account
2. Configure IAM user
3. Install AWS CLI
4. Configure credentials
5. Install Terraform
6. Install VS Code
7. Create project directory

Deliverable:

Shell

terraform version

aws sts get-caller-identity

works successfully.

---

# Phase 2: Terraform Foundation

Goal:

Create the Terraform project structure.

Structure:

Plain Text

aws-flight-events/

│

├── main.tf

├── variables.tf

├── outputs.tf

├── providers.tf

│

├── lambda/

│   ├── processor/

│   └── notifier/

│

└── terraform.tfvars

Deliverable:

Shell

terraform init

terraform validate

returns success.

---

# Phase 3: SNS Notifications

Goal:

Create an SNS topic and email subscription.

Terraform Resources:

Plain Text

aws_sns_topic

aws_sns_topic_subscription

Workflow:

Plain Text

SNS Topic

     |

     +--> Your Email

Deliverable:

Receive a test email from SNS.

---

# Phase 4: SQS Queue

Goal:

Create a queue that buffers incoming work.

Terraform Resources:

Plain Text

aws_sqs_queue

Workflow:

Plain Text

Event

  |

  v

SQS

Purpose:

Learn how asynchronous systems work.

Deliverable:

Send a test message manually.

Verify:

Shell

aws sqs receive-message

---

# Phase 5: Notification Lambda

Goal:

Create Lambda #2.

Function:

Python

def handler(event, context):

    print(event)

Workflow:

Plain Text

SQS

 |

 v

Lambda

Purpose:

Learn event-triggered compute.

Terraform Resources:

Plain Text

aws_lambda_function

aws_lambda_event_source_mapping

Deliverable:

Lambda executes automatically when a queue message arrives.

---

# Phase 6: SNS Integration

Goal:

Lambda publishes notifications.

Workflow:

Plain Text

Lambda

  |

  v

SNS

Example email:

Plain Text

Flight BA123 delayed 45 minutes.

Deliverable:

SQS message results in email notification.

---

# Phase 7: Event Processing Lambda

Goal:

Create Lambda #1.

This mimics flight-event handling.

Workflow:

Plain Text

Flight Event

      |

      v

Lambda

      |

      v

SQS

Example:

Input:

JSON

{

  "flightNumber": "BA123",

  "status": "DELAYED"

}

Output:

JSON

{

  "message": "Flight BA123 delayed"

}

Deliverable:

Lambda successfully writes to SQS.

---

# Phase 8: EventBridge

Goal:

Create the event bus.

Terraform Resources:

Plain Text

aws_cloudwatch_event_rule

aws_cloudwatch_event_target

Workflow:

Plain Text

EventBridge

    |

    v

Lambda #1

Deliverable:

EventBridge triggers Lambda.

---

# Phase 9: End-to-End Test

Goal:

Trigger a flight delay event manually.

Execute:

Shell

aws events put-events

Sample event:

JSON

{

  "Source": "airport.operations",

  "DetailType": "FlightDelay",

  "Detail": "{\"flightNumber\":\"BA123\",\"delayMinutes\":45}"

}

Expected path:

Plain Text

EventBridge

      |

      v

Lambda #1

      |

      v

SQS

      |

      v

Lambda #2

      |

      v

SNS

      |

      v

Email

Deliverable:

Email arrives.

---

# Phase 10: Observability

Goal:

Add operational monitoring.

Resources:

Plain Text

CloudWatch Logs

CloudWatch Metrics

CloudWatch Alarms

Track:

* Invocation count
* Errors
* Queue depth
* Failed notifications

Deliverable:

Alarm fires when Lambda errors occur.

---

# Phase 11: Interview Enhancements

Add:

### Dead Letter Queue

Plain Text

Lambda Failure

      |

      v

DLQ

Shows reliability engineering.

---

### Retry Logic

Shows resilience.

---

### Structured Logging

Example:

Python

logger.info({

    "flight": "BA123",

    "status": "DELAYED"

})

Shows observability mindset.

---

### Terraform Modules

Refactor into:

Plain Text

modules/

    lambda/

    sns/

    sqs/

Shows professional IaC practices.

---

# Interview Story

When completed you can confidently say:

> I built a serverless event-driven airport operations system in AWS using Terraform. Flight events were published to EventBridge, processed by Lambda, passed asynchronously through SQS, and used to trigger notifications through SNS. I added CloudWatch monitoring and alarms to improve observability and used Infrastructure as Code throughout the project.
>
