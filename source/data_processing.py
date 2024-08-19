import sagemaker
import boto3
import pandas as pd
import json
from sagemaker import get_execution_role
from datetime import datetime

# SageMaker 및 AWS 설정
role = get_execution_role()
session = sagemaker.Session()
region = session.boto_region_name
bucket = "esia-stock"

# S3 버킷 및 데이터 경로 설정
s3_data_prefix = 'AAPL/'
s3_data_path = f's3://{bucket}/{s3_data_prefix}'
output_path = f's3://{bucket}/deepar-output/'

# S3에서 데이터 불러오기
s3 = boto3.client('s3')

def load_s3_json_lines(bucket, prefix):
    all_data = []
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    for obj in response.get('Contents', []):
        key = obj['Key']
        if key.endswith('.json'):
            response = s3.get_object(Bucket=bucket, Key=key)
            data = response['Body'].read().decode('utf-8')
            all_data.extend(json.loads(line) for line in data.splitlines())
    return all_data

data = load_s3_json_lines(bucket, s3_data_prefix)

# 데이터프레임으로 변환
df = pd.DataFrame(data)

# # 타임스탬프를 사람이 읽을 수 있는 형식으로 변환 (밀리초 단위)
# df['date'] = pd.to_datetime(df['date'], unit='ms')

# 시계열 데이터 설정
df.set_index('date', inplace=True)
df = df[['close']]  # 'close' 가격만 사용

# 리샘플링하여 시계열 데이터 준비 (시간 빈도에 맞게)
df_resampled = df.resample('H').mean().dropna()

# 훈련 데이터와 테스트 데이터로 분할
train_size = int(len(df_resampled) * 0.8)
train_data = df_resampled[:train_size]
test_data = df_resampled[train_size:]

# DeepAR 형식으로 변환
def series_to_json_obj(ts, start):
    return {
        "start": str(start),
        "target": list(ts)
    }

train_series = series_to_json_obj(train_data, train_data.index[0])
test_series = series_to_json_obj(test_data, test_data.index[0])

# JSON Lines 형식으로 저장
train_json = json.dumps(train_series)
test_json = json.dumps(test_series)

# 로컬 파일로 저장
with open('train.json', 'w') as f:
    f.write(train_json + '\n')

with open('test.json', 'w') as f:
    f.write(test_json + '\n')

# S3에 업로드
train_s3_path = session.upload_data('train.json', bucket=bucket, key_prefix='deepar/data')
test_s3_path = session.upload_data('test.json', bucket=bucket, key_prefix='deepar/data')

print(f"Train data uploaded to: {train_s3_path}")
print(f"Test data uploaded to: {test_s3_path}")
