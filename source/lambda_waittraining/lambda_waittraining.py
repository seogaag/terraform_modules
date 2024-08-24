import boto3
import time

def handler(event, context):
    sagemaker = boto3.client('sagemaker')
    
    job_names = event['TrainingJobNames']  # 두 개의 TrainingJobName을 포함한 리스트
    job_statuses = {}
    
    while True:
        all_completed = True
        for job_name in job_names:
            response = sagemaker.describe_training_job(TrainingJobName=job_name)
            status = response['TrainingJobStatus']
            job_statuses[job_name] = status
            
            if status not in ['Completed', 'Failed', 'Stopped']:
                all_completed = False
        
        if all_completed:
            return {
                # "TrainingJobNames": job_names,
                "TrainingJobStatuses": job_statuses
            }
        
        # 트레이닝 작업이 완료될 때까지 대기
        time.sleep(60)  # 1분 대기 후 다시 확인
