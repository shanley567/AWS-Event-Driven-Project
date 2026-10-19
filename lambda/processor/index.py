import json
import boto3
import os

sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def handler(event, context):

    for record in event["Records"]:

        try:
            flight_event = json.loads(record["body"])

            flight_number = flight_event["flight_number"]
            origin = flight_event["origin"]
            destination = flight_event["destination"]
            try:
                delay_minutes = int(flight_event["delay_minutes"])
            except (ValueError, TypeError):
                raise ValueError(
                    f"Invalid delay_minutes value: {flight_event['delay_minutes']}"
                )

            print(
                json.dumps(
                    {
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

            else:
                print(
                    f"Flight {flight_number} delay of {delay_minutes} minutes does not require notification"
                )

        except Exception as e:

            print(
                json.dumps(
                    {
                        "error": str(e)
                    }
                )
            )

            raise

    return {
        "statusCode": 200
    }
