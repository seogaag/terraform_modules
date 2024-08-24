import json
import csv
import os
import boto3
from datetime import datetime



def handler(event, context):
    def load_json_from_s3(bucket_name, s3_key):
        s3 = boto3.client('s3')
        response = s3.get_object(Bucket=bucket_name, Key=s3_key)
        content = response['Body'].read().decode('utf-8')
        return json.loads(content)
    
    def load_json_lines_from_s3(bucket_name, s3_key):
        s3 = boto3.client('s3')
        response = s3.get_object(Bucket=bucket_name, Key=s3_key)
        content = response['Body'].read().decode('utf-8')
        
        json_objects = []
        for line in content.splitlines():
            json_objects.append(json.loads(line))
        
        return json_objects
    def format_date(date_str):
        # ISO 형식의 날짜를 파싱하여 'YYYY-MM-DD' 형식으로 변환
        return datetime.fromisoformat(date_str).strftime('%Y-%m-%d')
        
    def json_to_csv(bucket_name, prediction_key, train_key, eval_key, output_csv_key):
        s3 = boto3.client('s3')
        
        # 예측 데이터 로드
        prediction_data = load_json_from_s3(bucket_name, prediction_key)
        # 여러 줄로 된 JSON 객체들을 로드
        train_data = load_json_lines_from_s3(bucket_name, train_key)
        eval_data = load_json_lines_from_s3(bucket_name, eval_key)
        
        combined_data = []
        
        # for i in range(len(train_data)):
        #     starts.append(train_data[i]['start'])
        #     datas.append(train_data[i]['target'][0])
        
        # starts.append(eval_data[0]['start'])    
        # datas.append(eval_data[0]['target'][0])
    
        # today_date = datetime.now().strftime("%Y-%m-%d")
        # starts.append(today_date)
        # datas.append(prediction_data['current_model_predictions'])
        
        # row = {
        #     'time': starts,
        #     'target':  datas
        # }
        # combined_data.append(row)
        
        # train 데이터에서 start와 target 추출
        for train in train_data:
            formatted_start = format_date(train['start'])
            combined_data.append({
                'time': formatted_start,
                'target': train['target'][0]  # 첫 번째 타겟 값 사용
            })
        
        # eval 데이터에서 start와 target 추출
        if eval_data:
            formatted_start = format_date(eval_data[0]['start'])
            combined_data.append({
                'time': formatted_start,
                'target': eval_data[0]['target'][0]  # 첫 번째 타겟 값 사용
            })
    
        # prediction 데이터에서 today_date와 current_model_predictions 추출
        today_date = datetime.now().strftime("%Y-%m-%d")
        combined_data.append({
            'time': today_date,
            'target': prediction_data['current_model_predictions']  # 전체 예측 리스트 사용
        })
    
        
        # CSV 파일 생성 및 저장
        output_csv_path = '/tmp/output.csv'
        with open(output_csv_path, 'w', newline='') as csvfile:
            fieldnames = ['time', 'target']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            for data in combined_data:
                writer.writerow(data)
        
        # S3에 CSV 파일 업로드
        s3.upload_file(output_csv_path, bucket_name, output_csv_key)
        print(f'CSV file uploaded to s3://{bucket_name}/{output_csv_key}')
    companies = event['companies']
    for company in companies:
    # 사용 예제
        bucket_name = 'esia-stock-test-j'
        prediction_key = f'predictions/{company}/prediction-{datetime.now().strftime("%Y-%m-%d")}.json'
        train_key = f'processed/{company}/train.json'
        eval_key = f'processed/{company}/eval.json'
        output_csv_key = f'result/{company}_output.csv'
        
        json_to_csv(bucket_name, prediction_key, train_key, eval_key, output_csv_key)
