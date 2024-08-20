import boto3
import pandas as pd
import io
import os

def handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = os.environ['BUCKET_NAME']
    prefixes = os.environ['PREFIXES_LIST'].split(', ')
    
    for prefix in prefixes:
        all_data_frames = []
        
        raw_prefix = f'raw/{prefix}'
        processed_prefix = f'processed/{prefix}'
        
        # 주어진 prefix에 해당하는 모든 파일 리스트 가져오기
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=raw_prefix)

        for obj in response.get('Contents', []):
            key = obj['Key']

            if key.endswith('.json'):
                # JSON 파일 다운로드
                response = s3.get_object(Bucket=bucket_name, Key=key)
                data = response['Body'].read().decode('utf-8')

                try:
                    # JSON 데이터가 줄 바꿈으로 구분된 경우
                    try:
                        df = pd.read_json(io.StringIO(data), lines=True)
                    except ValueError:
                        # JSON 데이터가 일반 배열인 경우
                        df = pd.read_json(io.StringIO(data), lines=False)
                        
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
                    
                    # 모든 데이터프레임을 리스트에 추가
                    all_data_frames.append(df)
                    
                except Exception as e:
                    return {
                        "statusCode": 500,
                        "body": f"Failed to process file {key}: {str(e)}"
                    }
        
        # 모든 데이터프레임을 하나로 합치기
        all_data = pd.concat(all_data_frames)
        
        # 훈련 및 평가 데이터로 나누기 (예: 80% 훈련, 20% 평가)
        split_date = all_data['date'].max() - pd.DateOffset(days=30)  # 최근 30일을 평가 데이터로 사용
        train_df = all_data[all_data['date'] <= split_date]
        eval_df = all_data[all_data['date'] > split_date]
        
        # S3 저장 경로 지정
        train_key = f"{processed_prefix}train.csv"
        eval_key = f"{processed_prefix}eval.csv"
        
        # CSV로 변환 및 S3에 업로드
        csv_buffer = io.StringIO()
        train_df.to_csv(csv_buffer, index=False)
        s3.put_object(Bucket=bucket_name, Key=train_key, Body=csv_buffer.getvalue())
        
        csv_buffer = io.StringIO()
        eval_df.to_csv(csv_buffer, index=False)
        s3.put_object(Bucket=bucket_name, Key=eval_key, Body=csv_buffer.getvalue())
    
    return {'statusCode': 200, 'body': 'Data processed and saved'}
