import json
import boto3

s3_client = boto3.client('s3')

BUCKET_NAME = 'serverless-resume-bucket'
RESUME_FILE_KEY = 'resume.json'

def lambda_handler(event, context):
    try:
        response = s3_client.get_object(Bucket=BUCKET_NAME, Key=RESUME_FILE_KEY)
        resume_data = json.loads(response['Body'].read().decode('utf-8'))
        
        return {
            'statusCode': 200,
            'body': json.dumps(resume_data),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': str(e)
        }
