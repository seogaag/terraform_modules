# import json
# import boto3
# import requests
# from datetime import datetime
# import os

# s3 = boto3.client('s3')
# BUCKET_NAME = os.environ['BUCKET_NAME']
# API_KEY = os.environ['API_KEY']
# SYMBOLS = os.environ['SYMBOLS'].split(',')

# def lambda_handler(event, context):
#     for symbol in SYMBOLS:
#         url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&interval=1h&apikey={API_KEY}"
#         response = requests.get(url)
#         data = response.json()

#         timestamp = datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S')
#         file_name = f"{symbol}/{timestamp}.json"
#         s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=json.dumps(data))

#     return {
#         'statusCode': 200,
#         'body': json.dumps('Data collected and stored successfully')
#     }

import json
import boto3
import requests
from datetime import datetime
import os

# AWS S3 클라이언트 생성
s3 = boto3.client('s3')

# 환경 변수에서 값 가져오기
BUCKET_NAME = os.environ['BUCKET_NAME']
API_KEY = os.environ['API_KEY']
SYMBOLS = os.environ['SYMBOLS'].split(',')

def stock_collector(event, context):
    # 결과를 저장할 빈 리스트 초기화
    results = []

    # 각 회사 심볼에 대해 주가 데이터 요청
    for symbol in SYMBOLS:
        url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&interval=5min&apikey={API_KEY}"
        try:
            # API 요청
            response = requests.get(url)
            response.raise_for_status()  # HTTP 오류 발생 시 예외 발생
            
            # 데이터 파싱
            data = response.json()
            
            # 파일명에 타임스탬프 추가
            timestamp = datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S')
            file_name = f"{symbol}/{timestamp}.json"
            
            # S3에 데이터 저장
            s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=json.dumps(data))
            
            # 성공 메시지 추가
            results.append({'symbol': symbol, 'file': file_name, 'status': 'success'})
        
        except requests.exceptions.RequestException as e:
            # API 요청 오류 발생 시 결과에 실패 메시지 추가
            results.append({'symbol': symbol, 'status': 'failed', 'error': str(e)})

    # 모든 결과를 포함하여 응답 반환
    return {
        'statusCode': 200,
        'body': json.dumps(results)
    }
