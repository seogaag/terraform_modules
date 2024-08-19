import boto3
import pandas as pd
import io
import json

def handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = 'your-custom-bucket-name'
    
    # 폴더와 파일 경로를 기반으로 모든 파일 리스트 가져오기
    prefixes = ['AAPL/', 'NVDA/']
    for prefix in prefixes:
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        for obj in response.get('Contents', []):
            key = obj['Key']
            
            # JSON 파일 다운로드
            response = s3.get_object(Bucket=bucket_name, Key=key)
            data = response['Body'].read().decode('utf-8')
            df = pd.read_json(io.StringIO(data), lines=True)
            
            # 타임스탬프를 날짜로 변환
            df['date'] = pd.to_datetime(df['date'], unit='ms')
            df.rename(columns={
                'volume': 'volume',
                'open': 'open',
                'close': 'close',
                'high': 'high',
                'low': 'low',
                'transactions': 'transactions'
            }, inplace=True)
            
            # 전처리된 데이터를 S3에 저장
            processed_key = key.replace('.json', '_processed.csv')
            csv_buffer = df.to_csv(index=False)
            s3.put_object(Bucket=bucket_name, Key=processed_key, Body=csv_buffer)

    return {'statusCode': 200, 'body': 'Data processed and saved'}
