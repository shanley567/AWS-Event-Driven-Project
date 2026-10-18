import json
import boto3
import os

# Initialize AWS clients outside the handler for connection reuse
sns = boto3.client("sns")

# Fail immediately if the variable is missing
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def handler(event, context):
    """
    Processes messages received from SQS and republishes
    them to an SNS topic.
    """

    print(json.dumps({
        "event": "lambda_invoked",
        "records_received": len(event.get("Records", []))
    }))

    for record in event["Records"]:
        try:
            message_id = record["messageId"]
            message_body = record["body"]

            print(json.dumps({
                "event": "processing_message",
                "message_id": message_id,
                "message_body": message_body
            }))

            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"Flight Alert:\n{message_body}",
                Subject="Flight Status Update"
            )

            print(json.dumps({
                "event": "message_processed",
                "message_id": message_id
            }))

        except Exception as e:
            print(json.dumps({
                "event": "processing_failed",
                "message_id": record.get("messageId"),
                "error": str(e)
            }))

            raise

    return {
        "statusCode": 200,
        "body": json.dumps("Success")
    }