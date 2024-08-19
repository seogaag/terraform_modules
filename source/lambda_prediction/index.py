import boto3
import json
from datetime import datetime

def handler(event, context):
    sagemaker = boto3.client('sagemaker-runtime')
    s3 = boto3.client('s3')

    # S3에서 오늘의 데이터 가져오기 (가정: 오늘 날짜의 데이터는 'today_data.json' 파일에 저장되어 있음)
    bucket_name = 'your-custom-bucket-name'
    key = 'AAPL/today_data.json'
    
    response = s3.get_object(Bucket=bucket_name, Key=key)
    today_data = response['Body'].read().decode('utf-8')

    # 모델 예측
    endpoint_name = 'your-model-endpoint'
    response = sagemaker.invoke_endpoint(
        EndpointName=endpoint_name,
        Body=today_data,
        ContentType='application/json'
    )
    
    predictions = response['Body'].read().decode('utf-8')
    
    # 예측 결과를 S3에 저장
    prediction_key = 'AAPL/today_predictions.json'
    s3.put_object(Bucket=bucket_name, Key=prediction_key, Body=predictions)
    
    return {'statusCode': 200, 'body': 'Prediction saved to S3'}
