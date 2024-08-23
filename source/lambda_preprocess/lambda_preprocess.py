
import boto3
import pandas as pd
import io
import os
import json

def handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = os.environ['BUCKET_NAME']
    # prefixes = os.environ['PREFIXES_LIST'].split(', ')
    # companies = event['companies']
    companies = ['AAPL','NVDA']
    results = {"companies": []}
    
    for company in companies:
        all_data_frames = []
        
        raw_prefix = f'raw/{company}/'
        processed_prefix = f'processed/{company}/'
        
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
        split_date = all_data['date'].max() - pd.DateOffset(days=1)  # 최근 30일을 평가 데이터로 사용
        train_df = all_data[all_data['date'] <= split_date]
        eval_df = all_data[all_data['date'] > split_date]
        
        # S3 저장 경로 지정
        train_key = f"{processed_prefix}train.json"
        eval_key = f"{processed_prefix}eval.json"
        
        # JSON Lines 형식으로 변환 및 S3에 업로드
        def save_json_lines_to_s3(df, s3_key):
            json_buffer = io.StringIO()
            for start, group_df in df.groupby(df['date'].dt.to_period('D')):
                # Convert the 'start' timestamp and 'target' values
                # dynamic_feature = []
                
                # dynamic_feature.append(group_df['open'].tolist())
                # dynamic_feature.append(group_df['high'].tolist())
                # dynamic_feature.append(group_df['low'].tolist())
                # dynamic_feature.append(group_df['volume'].tolist())
                # dynamic_feature.append(group_df['transactions'].tolist())
                
                json_record = {
                    "start": start.start_time.isoformat(),  # ISO 8601 포맷
                    "target": group_df['close'].tolist()  # 'close'를 'target'으로 사용
                    # Add dynamic features if needed
                    # "dynamic_features": 
                    #     # dynamic_feature
                    #     "open": group_df['open'].tolist,
                    #     "high": group_df['high'].tolist,
                    #     "low": group_df['low'].tolist,
                    #     "volume": group_df['volume'].tolist,
                    #     "transactions": group_df['transactions'].tolist
                    
                }
                json.dump(json_record, json_buffer)
                json_buffer.write('\n')  # 각 객체를 새 줄로 구분
            
            s3.put_object(Bucket=bucket_name, Key=s3_key, Body=json_buffer.getvalue())
        
        save_json_lines_to_s3(train_df, train_key)
        save_json_lines_to_s3(eval_df, eval_key)

        results["companies"].append(company)
    return results
