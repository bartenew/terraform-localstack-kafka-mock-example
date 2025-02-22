import json
import boto3
import os
import base64

# Initialize DynamoDB
dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE")
table = dynamodb.Table(table_name)


def lambda_handler(event, context):
    """
    AWS Lambda function to process Kafka messages and store them in DynamoDB.
    """
    try:
        if "records" not in event:
            print("No records found in the event.")
            return {"statusCode": 400, "body": "No records in event"}

        for topic_partition, messages in event["records"].items():
            for message in messages:
                try:
                    # Decode Base64 value
                    kafka_message = base64.b64decode(message["value"]).decode("utf-8")
                    permit_data = json.loads(kafka_message)  # Parse JSON

                    # Ensure permit_id exists as the primary key
                    if "permit_id" not in permit_data:
                        print(f"Skipping message: missing permit_id in {permit_data}")
                        continue

                    # Remove None values (DynamoDB does not accept them)
                    sanitized_data = {k: v for k, v in permit_data.items() if v is not None}

                    # Save to DynamoDB
                    table.put_item(Item=sanitized_data)

                    print(f"Saved building permit: {permit_data['permit_id']}")

                except Exception as e:
                    print(f"Error processing message: {message}")
                    print(f"Error details: {e}")

        return {"statusCode": 200, "body": "Building permits processed successfully."}

    except Exception as e:
        print(f"Fatal error: {e}")
        return {"statusCode": 500, "body": "Error processing building permits."}
