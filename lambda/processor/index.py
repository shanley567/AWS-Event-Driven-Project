import json
import boto3
import os

from validator import validate_event

sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def handler(event, context):

    print(
        json.dumps(
            {
                "event": "lambda_invoked",
                "records_received": len(event["Records"])
            }
        )
    )

    for record in event["Records"]:

        try:

            flight_event = json.loads(record["body"])

            validated_event = validate_event(
                flight_event
            )

            flight_number = validated_event["flight_number"]
            origin = validated_event["origin"]
            destination = validated_event["destination"]
            delay_minutes = validated_event["delay_minutes"]

            print(
                json.dumps(
                    {
                        "event": "flight_event_received",
                        "flight_number": flight_number,
                        "delay_minutes": delay_minutes
                    }
                )
            )

            if delay_minutes >= 15:

                sns.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject=f"Flight Delay Alert - {flight_number}",
                    Message=f"""
Flight: {flight_number}

Origin: {origin}

Destination: {destination}

Delay: {delay_minutes} minutes
"""
                )

                print(
                    json.dumps(
                        {
                            "event": "notification_sent",
                            "flight_number": flight_number,
                            "delay_minutes": delay_minutes
                        }
                    )
                )

            else:

                print(
                    json.dumps(
                        {
                            "event": "notification_not_required",
                            "flight_number": flight_number,
                            "delay_minutes": delay_minutes
                        }
                    )
                )

        except Exception as e:

            print(
                json.dumps(
                    {
                        "event": "validation_or_processing_failed",
                        "error": str(e),
                        "message_body": record["body"]
                    }
                )
            )

            raise

    return {
        "statusCode": 200,
        "body": json.dumps("Success")
    }