import boto3
import os

def main():
    sagemaker_client = boto3.client('sagemaker', region_name='ap-south-1')

    response = sagemaker_client.create_training_job(
        TrainingJobName=os.getenv('TRAINING_JOB_NAME'),
        AlgorithmSpecification={
            'TrainingImage': os.getenv('TRAINING_IMAGE'),
            'TrainingInputMode': 'File'
        },
        InputDataConfig=[
            {
                'ChannelName': 'train',
                'DataSource': {
                    'S3DataSource': {
                        'S3DataType': 'S3Prefix',
                        'S3Uri': os.getenv('TRAINING_DATA_S3_URI')
                    }
                },
                'ContentType': 'application/x-recordio'
            }
        ],
        OutputDataConfig={
            'S3OutputPath': os.getenv('MODEL_OUTPUT_S3_URI')
        },
        ResourceConfig={
            'InstanceType': os.getenv('INSTANCE_TYPE'),
            'InstanceCount': int(os.getenv('INSTANCE_COUNT')),
            'VolumeSizeInGB': int(os.getenv('VOLUME_SIZE_IN_GB'))
        },
        RoleArn=os.getenv('SAGEMAKER_ROLE_ARN'),
        StoppingCondition={
            'MaxRuntimeInSeconds': int(os.getenv('MAX_RUNTIME_IN_SECONDS'))
        }
    )

    print(response)

if __name__ == '__main__':
    main()
