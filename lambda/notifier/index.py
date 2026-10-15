import json
import boto3
import os

# Clients are initialized outside the handler for faster subsequent calls (warm starts)
sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def handler(event, context):
    try:
        # SQS delivers messages in a list called 'Records'
        for record in event['Records']:
            message_body = record['body']
            print(f"---Processing SQS Message:---\n{message_body}")
            
            # Send the message to the SNS Topic
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"---Flight Alert:---\n{message_body}",
                Subject="Flight Status Update"
            )
            
        return {'statusCode': 200, 'body': 'Success'}
    except Exception as e:
        print(f"---Error:---\n {str(e)}")
        raise e # Raising the error tells SQS to keep the message for retry