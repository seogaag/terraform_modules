import boto3

def handler(event, context):
    sagemaker = boto3.client('sagemaker')

    # SageMaker 트레이닝 작업 시작
    response = sagemaker.create_training_job(
        TrainingJobName='MyTrainingJob',
        AlgorithmSpecification={
            'TrainingImage': 'your-sagemaker-image-uri',
            'TrainingInputMode': 'File'
        },
        RoleArn='your-sagemaker-role-arn',
        InputDataConfig=[
            {
                'ChannelName': 'training',
                'DataSource': {
                    'S3DataSource': {
                        'S3DataType': 'S3Prefix',
                        'S3Uri': 's3://your-custom-bucket-name/AAPL/processed_stock_data_*.csv'
                    }
                }
            }
        ],
        OutputDataConfig={
            'S3OutputPath': 's3://your-custom-bucket-name/model-output/'
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
