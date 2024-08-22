import boto3
import os
from datetime import datetime

def handler(event, context):
    sagemaker = boto3.client('sagemaker')
    bucket_name = os.environ['BUCKET_NAME']
    role_arn = os.environ['SAGEMAKER_ROLE']
    companies = event['companies']
    today_date = datetime.now().strftime("%Y-%m-%d")
    # companies = ['AAPL','NVDA']
    job_names = []
    for company in companies:

        training_job_name = f'ESIATrainingJob-{company}-{today_date}214'
        job_names.append(training_job_name)
        # SageMaker 트레이닝 작업 시작
        response = sagemaker.create_training_job(
            TrainingJobName=training_job_name,
            AlgorithmSpecification={
                'TrainingImage': '991648021394.dkr.ecr.ap-south-1.amazonaws.com/forecasting-deepar:latest',
                'TrainingInputMode': 'File'
            },
            RoleArn=role_arn,
            InputDataConfig=[
                {
                    'ChannelName': 'train',
                    'DataSource': {
                        'S3DataSource': {
                            'S3DataType': 'S3Prefix',
                            'S3Uri': f's3://{bucket_name}/processed/{company}/train.json'
                        }
                    },
                    'InputMode': 'File'
                }
            ],
            OutputDataConfig={
                'S3OutputPath': f's3://{bucket_name}/model-output/{company}/'
            },
            ResourceConfig={
                'InstanceType': 'ml.m4.xlarge',
                'InstanceCount': 1,
                'VolumeSizeInGB': 30
            },
            StoppingCondition={
                'MaxRuntimeInSeconds': 3600
            },
            HyperParameters={
                'time_freq': '5min',
                'epochs': '50',    # 훈련 에포크 수
                'context_length': '15',  # 과거 데이터 길이
                'prediction_length': '1'  # 미래 예측 길이
            }
        )
        
    return {
        "statusCode": 200,
        "TrainingJobNames": job_names
    }