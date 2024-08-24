import boto3
import os
from datetime import datetime, timedelta
from botocore.exceptions import ClientError

def handler(event, context):
    sagemaker = boto3.client('sagemaker')
    bucket_name = os.environ['BUCKET_NAME']
    role_arn = os.environ['SAGEMAKER_ROLE']
    companies = event['companies']
    today_date = datetime.now().strftime("%Y-%m-%d")
    yesterday = datetime.now() - timedelta(days=1)
    yester_date = yesterday.strftime("%Y-%m-%d")
    # companies = ['AAPL','NVDA']
    job_names = []
    
    def training_job_exists(sagemaker_client, training_job_name):
        try:
            sagemaker_client.describe_training_job(TrainingJobName=training_job_name)
            return True
        except ClientError as e:
            if e.response['Error']['Code'] == 'ValidationException':
                return False
            else:
                raise
    
    for company in companies:
        
        training_job_name = f'ESIATrainingJob-{company}-{yester_date}'
        job_names.append(training_job_name)
        if training_job_exists(sagemaker, training_job_name):
            print("TrainingJobExists...")
        else:
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