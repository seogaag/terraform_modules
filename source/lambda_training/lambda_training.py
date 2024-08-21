import boto3

def handler(event, context):
    sagemaker = boto3.client('sagemaker')

    # SageMaker 트레이닝 작업 시작
    response = sagemaker.create_training_job(
        TrainingJobName='ESIATrainingJob',
        AlgorithmSpecification={
            'TrainingImage': '991648021394.dkr.ecr.ap-south-1.amazonaws.com/forecasting-deepar:latest',
            'TrainingInputMode': 'File'
        },
        RoleArn='arn:aws:iam::381492185710:role/esia-test_sagemaker_role',
        InputDataConfig=[
            {
                'ChannelName': 'training',
                'DataSource': {
                    'S3DataSource': {
                        'S3DataType': 'S3Prefix',
                        'S3Uri': 's3://esia-stock-test/processed/*.csv'
                    }
                }
            }
        ],
        OutputDataConfig={
            'S3OutputPath': 's3://esia-stock-test/model-output/'
        },
        ResourceConfig={
            'InstanceType': 'ml.m4.xlarge',
            'InstanceCount': 1,
            'VolumeSizeInGB': 30
        },
        StoppingCondition={
            'MaxRuntimeInSeconds': 3600
        }
    )
    
    return {'statusCode': 200, 'body': json.dumps('Training job started')}

# import boto3
# import sagemaker
# from sagemaker import TrainingInput
# from sagemaker.estimator import Estimator
# import os

# def handler(event, context):
#     s3 = boto3.client('s3')
#     bucket_name = os.environ['BUCKET_NAME']
#     companies = event['companies']
#     # company = os.environ['companies'].split(', ')
    
#     for company in companies:
#         train_path = f's3://{bucket_name}/processed/{company}/train.csv'
        
#         # SageMaker Estimator 설정
#         estimator = Estimator(
#             image_uri='991648021394.dkr.ecr.ap-south-1.amazonaws.com/forecasting-deepar:latest',
#             role=os.environ['SAGEMAKER_ROLE'],
#             instance_count=1,
#             instance_type='ml.m5.large',
#             output_path=f's3://{bucket_name}/model_output/{company}/'
#         )
        
#         # 모델 학습 시작
#         estimator.fit({'train': TrainingInput(train_path, content_type='text/csv')})
        
#         model_artifact = estimator.model_data
        
#         # 모델 경로를 다음 단계에 전달
#         event['model_artifact'] = model_artifact
    
#     return event
