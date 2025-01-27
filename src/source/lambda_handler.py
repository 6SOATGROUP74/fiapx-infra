import json
import boto3
import os


sqs_client = boto3.client('sqs')

def lambda_handler(event, context):
    
    try:
        QUEUE_URL = os.environ['QUEUE_URL']
        records = event.get('Records', [])
        
        for record in records:

            s3_object_key = record.get('s3', {}).get('object', {}).get('key')
            if not s3_object_key:
                continue
            
            response = sqs_client.send_message(
                QueueUrl=QUEUE_URL,
                MessageBody=json.dumps({"key": s3_object_key}),
                MessageGroupId='default-group'
            )
            print(f"Mensagem enviada para o SQS: {response['MessageId']}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Mnesagem enviada com sucesso"})
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"erro ao enviar mensagem para o sqs": str(e)})
        }
