import boto3
import json
import os
import datetime
import time
from datetime import datetime, timedelta

from botocore.exceptions import ClientError

def handler(event, context):
    sagemaker_runtime = boto3.client('sagemaker-runtime')
    sagemaker = boto3.client('sagemaker')
    s3 = boto3.client('s3')
    
    bucket_name = os.environ['BUCKET_NAME']
    role_arn = os.environ['SAGEMAKER_ROLE']
    # companies = event['companies']
    companies = ['AAPL','NVDA']
    # training_job_names = event['TraingJobNames']
    
    def model_exists(sagemaker_client, model_name):
        try:
            sagemaker_client.describe_model(ModelName=model_name)
            return True
        except ClientError as e:
            if e.response['Error']['Code'] == 'ValidationException':
                return False
            else:
                raise
    
    def endpoint_exists(sagemaker_client, endpoint_name):
        try:
            sagemaker_client.describe_endpoint(EndpointName=endpoint_name)
            return True
        except ClientError as e:
            if e.response['Error']['Code'] == 'ValidationException':
                return False
            else:
                raise
    
    def endpoint_config_exists(sagemaker_client, endpoint_config_name):
        try:
            sagemaker_client.describe_endpoint_config(EndpointConfigName=endpoint_config_name)
            return True
        except ClientError as e:
            if e.response['Error']['Code'] == 'ValidationException':
                return False
            else:
                raise
    
    def wait_for_endpoint_in_service(sagemaker_client, endpoint_name):
        print(f"Waiting for endpoint {endpoint_name} to be InService...")
        while True:
            response = sagemaker_client.describe_endpoint(EndpointName=endpoint_name)
            status = response['EndpointStatus']
            if status == 'InService':
                print(f"Endpoint {endpoint_name} is now InService.")
                break
            elif status in ['Failed', 'OutOfService']:
                raise Exception(f"Endpoint {endpoint_name} failed with status: {status}")
            else:
                print(f"Current status: {status}. Waiting...")
                time.sleep(30)  # 30초 후에 다시 확인
    
    def create_model(model_name, training_job_name, model_artifact, image_uri):
        sagemaker = boto3.client('sagemaker')
        
        if model_exists(sagemaker, model_name):
            print("Model is exists... Skip creating")
        else:
            response = sagemaker.create_model(
                ModelName=model_name,
                PrimaryContainer={
                    'Image': '991648021394.dkr.ecr.ap-south-1.amazonaws.com/forecasting-deepar:latest',
                    'ModelDataUrl': f's3://{bucket_name}/model-output/{company}/{training_job_name}/output/model.tar.gz'
                },
                ExecutionRoleArn=role_arn
            )

    def create_endpoint(model_name, endpoint_config_name, endpoint_name):
        
        sagemaker = boto3.client('sagemaker')
        if not endpoint_config_exists(sagemaker, endpoint_config_name):
            try:
                response = sagemaker.create_endpoint_config(
                    EndpointConfigName=endpoint_config_name,
                    ProductionVariants=[
                        {
                            'VariantName': 'AllTrafficVariant',
                            'ModelName': model_name,
                            'InstanceType': 'ml.m4.xlarge',
                            'InitialInstanceCount': 1
                        }
                    ]
                )
                print(f"Endpoint config {endpoint_config_name} created successfully.")
            except ClientError as e:
                if e.response['Error']['Code'] == 'ValidationException' and 'already exists' in e.response['Error']['Message']:
                    print(f"Endpoint config {endpoint_config_name} already exists. Using the existing config.")
                else:
                    raise
        else:
            print(f"Endpoint config {endpoint_config_name} already exists. Using the existing config.")
        
        if endpoint_exists(sagemaker, endpoint_name):
            print(f"Endpoint {endpoint_name} already exists. Using the existing endpoint.")
        else:
            print(f"Creating new endpoint: {endpoint_name}")
            response = sagemaker.create_endpoint(
                EndpointName=endpoint_name,
                EndpointConfigName=endpoint_config_name
            )
            print(f"Endpoint {endpoint_name} creation started.")
            wait_for_endpoint_in_service(sagemaker, endpoint_name)

    def calculate_mae(predicted_values, actual_values):
        # 입력이 리스트가 아닌 경우, 리스트로 변환

        # if len(predicted_values) == 0 or len(actual_values) == 0:
        #     return None
        
        # if len(predicted_values) > len(actual_values):
        #     predicted_values = predicted_values[:len(actual_values)]
        actual_values = actual_values.get('target')[0]
        
        # MAE 계산
        # absolute_errors = [abs(float(p) - float(a)) for p, a in zip(predicted_values, actual_values)
        absolute_errors = [abs(predicted_values - actual_values)]
        
        mae = sum(absolute_errors) / len(absolute_errors)
        return mae

    for company in companies:
        # today_date = datetime.now().strftime("%Y-%m-%d")
        
        yesterday = datetime.now() - timedelta(days=2)
        yester_date = yesterday.strftime("%Y-%m-%d")

        yyesterday = datetime.now() - timedelta(days=3)
        yyester_date = yyesterday.strftime("%Y-%m-%d")

        # SageMaker 엔드포인트 이름
        current_model_endpoint_name = f'{company}-forecasting-endpoint-{yyester_date}01'
        current_model_name = f'{company}-deepAR-{yyester_date}01'
        current_endpoint_config_name = f'{company}-endpoint-config-{yyester_date}01'
        current_training_job_name = f'ESIATrainingJob-{company}-{yyester_date}803'
        
        create_model(current_model_name, current_training_job_name, current_endpoint_config_name, current_model_endpoint_name)
        create_endpoint(current_model_name, current_endpoint_config_name, current_model_endpoint_name)
        
        # 오늘 날짜
        # today_date_time = datetime.now().strftime("%Y-%m-%dT00:00:00")
        
        def get_eval_target_data():
            s3_key = f'processed/{company}/eval.json'
            try:
                response = s3.get_object(Bucket=bucket_name, Key=s3_key)
                file_content = response['Body'].read().decode('utf-8')
                
                # JSON 배열로 파싱
                eval_instances = json.loads(file_content)
                
                return eval_instances
        
            except Exception as e:
                print(f"Error fetching eval data: {str(e)}")
                return []
            
        
        
        # 평가 데이터 생성 (예시)
        start_data = get_eval_target_data()
        eval_instance = {
            "instances": [
                {
                    "start": start_data.get("start"),
                    "target": []    
                }
            ]
           
        }
        
        # 평가할 데이터 가져오기
        def get_actual_values():
            try:
                s3_key = f'processed/{company}/eval.json'
                response = s3.get_object(Bucket=bucket_name, Key=s3_key)
                file_content = response['Body'].read().decode('utf-8')
                # JSON 배열로 파싱
                data = json.loads(file_content)
                actual_datas = {
                    "start": data['start'],
                    "target": data['target']
                }
                return actual_datas
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON: {e}")
                return []
            except Exception as e:
                print(f"Error fetching actual values: {str(e)}")
                return []
        
        actual_values = get_actual_values()
        
        # 모델 평가 함수
        def evaluate_model(endpoint_name):
            try:
                response = sagemaker_runtime.invoke_endpoint(
                    EndpointName=endpoint_name,
                    ContentType='application/json',
                    Body=json.dumps(eval_instance)
                )
                
                # 응답 처리
                response_body = response['Body'].read().decode('utf-8')
                # 예측값 추출
                predicted_result = json.loads(response_body)
                print(predicted_result['predictions'][0]['mean'][0])
                predicted_values = predicted_result['predictions'][0]['mean'][0]
                
                # MAE 계산
                mae = calculate_mae(predicted_values, actual_values)
                
                return mae, predicted_values
            
            except Exception as e:
                print(f"Error evaluating model {endpoint_name}: {str(e)}")
                return None, None
        
        # 새 모델을 평가할 때 사용하는 엔드포인트 이름
        new_model_endpoint_name = f'{company}-forecasting-endpoint-{yester_date}01'
        new_model_name = f'{company}-deepAR-{yester_date}01'
        new_model_endpoint_config_name = f'{company}-endpoint-config-{yester_date}01'
        new_training_job_name = f'ESIATrainingJob-{company}-{yester_date}803'

        create_model(new_model_name, new_training_job_name, new_model_endpoint_config_name, new_model_endpoint_name)
        create_endpoint(new_model_name, new_model_endpoint_config_name, new_model_endpoint_name)
        
        # 새 모델과 현재 모델 평가
        new_model_mae, new_model_predictions = evaluate_model(new_model_endpoint_name)
        current_model_mae, current_model_predictions = evaluate_model(current_model_endpoint_name)
        
        # 성능 비교 및 모델 결정
        if new_model_mae is not None and (current_model_mae is None or new_model_mae < current_model_mae):
            chosen_endpoint = new_model_endpoint_name
            best_mae = new_model_mae
        else:
            chosen_endpoint = current_model_endpoint_name
            best_mae = current_model_mae

        print(json.dumps({
            "selected_endpoint": chosen_endpoint,
            "best_mae": best_mae,
            "new_model_mae": new_model_mae,
            "current_model_mae": current_model_mae,
            "new_model_predictions": new_model_predictions,
            "current_model_predictions": current_model_predictions
        }))

