import requests
import pandas as pd
from datetime import datetime, timedelta
import os
import boto3


def handler(event, context):
    api_key = os.environ['API_KEY']
    # companies = event['companies']
    companies = ['AAPL', 'NVDA']
    bucket_name = os.environ['BUCKET_NAME']
    # bucket_name = "esia-stock-test"
    
    s3_client = boto3.client('s3')


    # API 요청 URL 설정
    for ticker in companies:
        today_date = datetime.now()
        # yesterday = today_date - timedelta(days=1)
        # yester_date = yesterday.strftime("%Y-%m-%d")
        start_date = "2024-07-01"
        end_date = "2024-08-30"
        url = f"https://api.polygon.io/v2/aggs/ticker/{ticker}/range/5/minute/{start_date}/{end_date}?adjusted=true&sort=asc&limit=50000&apiKey={api_key}"

        # API 요청
        response = requests.get(url)
        data = response.json()


        # 데이터프레임으로 변환
        df = pd.DataFrame(data['results'])

        # 타임스탬프를 날짜로 변환
        df['date'] = pd.to_datetime(df['t'], unit='ms').dt.strftime('%Y-%m-%d %H:%M:%S')

        # 열 이름 변경
        df.rename(columns={
            'o': 'open',
            'h': 'high',
            'l': 'low',
            'c': 'close',
            'v': 'volume',
            'n': 'transactions'
        }, inplace=True)

        # 필요없는 열 삭제 (원래의 't' 열 등)
        df.drop(columns=['t', 'vw'], inplace=True)

        # '/tmp' 디렉터리 사용
        output_dir = f'/tmp/{ticker}/'
        os.makedirs(output_dir, exist_ok=True)

        output_file = os.path.join(output_dir, f'{start_date}_{end_date}.json')
        df.to_json(output_file, orient='records', lines=True)

        # S3에 파일 업로드
        s3_key = f'raw/{ticker}/{start_date}_{end_date}.json'
        s3_client.upload_file(output_file, bucket_name, s3_key)

        # /tmp 디렉터리의 파일 삭제 (선택적)
        os.remove(output_file)