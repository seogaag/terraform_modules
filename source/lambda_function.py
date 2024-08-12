import json
import boto3
import requests
from datetime import datetime
import os

s3 = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']
API_KEY = os.environ['API_KEY']
SYMBOLS = os.environ['SYMBOLS'].split(',')

def lambda_handler(event, context):
    for symbol in SYMBOLS:
        url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&interval=1h&apikey={API_KEY}"
        response = requests.get(url)
        data = response.json()

        timestamp = datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S')
        file_name = f"{symbol}/{timestamp}.json"
        s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=json.dumps(data))

    return {
        'statusCode': 200,
        'body': json.dumps('Data collected and stored successfully')
    }
