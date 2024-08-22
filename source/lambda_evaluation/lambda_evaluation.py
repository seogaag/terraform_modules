# import boto3
# import json
# import os
# import datetime

# def create_endpoint(model_name, endpoint_config_name, endpoint_name):
#     sagemaker = boto3.client('sagemaker')
    
#     # 엔드포인트 구성 생성
#     response = sagemaker.create_endpoint_config(
#         EndpointConfigName=endpoint_config_name,
#         ProductionVariants=[
#             {
#                 'VariantName': 'AllTrafficVariant',
#                 'ModelName': model_name,
#                 'InstanceType': 'ml.m4.xlarge',
#                 'InitialInstanceCount': 1
#             }
#         ]
#     )

#     # 엔드포인트 생성
#     response = sagemaker.create_endpoint(
#         EndpointName=endpoint_name,
#         EndpointConfigName=endpoint_config_name
#     )

# def handler(event, context):
#     sagemaker_runtime = boto3.client('sagemaker-runtime')
#     s3 = boto3.client('s3')
    
#     bucket_name = os.environ['BUCKET_NAME']
#     companies = ['AAPL', 'NVDA']
    
#     results = {}

#     for company in companies:
#         # SageMaker 엔드포인트 이름
#         model_name=f'{company}-deepAR'
#         endpoint_config_name = f'{company}-endpoint-config'
#         endpoint_name = f'{company}-endpoint'
        
#         create_endpoint(model_name, endpoint_config_name, endpoint_name)

#         # 평가 결과 파일 읽기
#         evaluation_prefix = f'processed/{company}/eval.json'
#         response = s3.list_objects_v2(Bucket=bucket_name, Prefix=evaluation_prefix)
#         evaluation_files = sorted(
#             [obj['Key'] for obj in response.get('Contents', []) if obj['Key'].endswith('.json')],
#             reverse=True
#         )
        
#         # 가장 최근 평가 결과 파일 선택
#         if evaluation_files:
#             latest_eval_key = evaluation_files[0]
#             response = s3.get_object(Bucket=bucket_name, Key=latest_eval_key)
#             evaluation_data = json.loads(response['Body'].read().decode('utf-8'))
#             # 평가 결과 확인 (예: MAE 기준으로 모델 성능 판단)
#             latest_mae = min([item['mae'] for item in evaluation_data if item['mae'] is not None], default=float('inf'))
#             use_latest_model = latest_mae < threshold  # threshold는 설정한 MAE 기준
#         else:
#             use_latest_model = False
        
#         # 예측을 위한 데이터 준비
#         prediction_key = f'processed/{company}/predict.json'
#         response = s3.get_object(Bucket=bucket_name, Key=prediction_key)
#         predict_data = {
#             "start": 
#         }
        
#         company_results = []
#         for record in predict_data:
#             predict_instance = json.loads(record)
            
#             # 예측할 부분의 target을 비우고 SageMaker 엔드포인트 호출
#             predict_instance['target'] = []  # 예측할 부분을 비움
            
#             try:
#                 response = sagemaker_runtime.invoke_endpoint(
#                     EndpointName=endpoint_name,
#                     ContentType='application/json',
#                     Body=json.dumps({"instances": [predict_instance]})
#                 )
                
#                 # 응답 처리
#                 predicted_result = json.loads(response['Body'].read().decode('utf-8'))
#                 predicted_values = predicted_result[0]['quantiles']['0.5']  # 중간값(50% 확률)의 예측값
                
#                 # 예측 결과 S3에 저장
#                 company_results.append({
#                     "start": predict_instance['start'],
#                     "predicted": predicted_values
#                 })
            
#             except Exception as e:
#                 return {
#                     "statusCode": 500,
#                     "body": f"Failed to get prediction for {company}: {str(e)}"
#                 }
        
#         results[company] = company_results
        
#         # 예측 결과 S3에 저장
#         s3_key = f'predictions/{company}/{datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")}.json'
#         s3.put_object(Bucket=bucket_name, Key=s3_key, Body=json.dumps(company_results))
    
#     return {
#         "statusCode": 200,
#         "body": json.dumps(results)
#     }


# import boto3
# import json
# import os
# import datetime
# import numpy as np

# def handler(event, context):
#     sagemaker_runtime = boto3.client('sagemaker-runtime')
#     s3 = boto3.client('s3')
    
#     bucket_name = os.environ['BUCKET_NAME']
#     companies = ['AAPL', 'NVDA']

#     def create_endpoint(model_name, endpoint_config_name, endpoint_name):
#         sagemaker = boto3.client('sagemaker')
        
#         # 엔드포인트 구성 생성
#         response = sagemaker.create_endpoint_config(
#             EndpointConfigName=endpoint_config_name,
#             ProductionVariants=[
#                 {
#                     'VariantName': 'AllTrafficVariant',
#                     'ModelName': model_name,
#                     'InstanceType': 'ml.m4.xlarge',
#                     'InitialInstanceCount': 1
#                 }
#             ]
#         )

#         # 엔드포인트 생성
#         response = sagemaker.create_endpoint(
#             EndpointName=endpoint_name,
#             EndpointConfigName=endpoint_config_name
#         )

#     for company in companies:
#         # SageMaker 엔드포인트 이름
#         current_model_endpoint_name = f'{company}-forecasting-endpoint'
#         model_name=f'{company}-deepAR'
#         endpoint_config_name = f'{company}-endpoint-config'

#         create_endpoint(model_name, endpoint_config_name, current_model_endpoint_name)
        
#         # 오늘 날짜
#         today_date = datetime.datetime.now().strftime("%Y-%m-%dT00:00:00")
        
#         # 평가 데이터 생성 (예시)
#         eval_instance = {
#             "start": today_date,
#             "target": []
#             # "dynamic_features": []
#         }
        
#         # 평가할 데이터 가져오기
#         def get_actual_values():
#             try:
#                 # 예시로 실제 값을 빈 리스트로 설정
#                 s3_key = f'actual_data/{company}/{today_date}.json'
#                 response = s3.get_object(Bucket=bucket_name, Key=s3_key)
#                 actual_data = json.loads(response['Body'].read().decode('utf-8'))
#                 return actual_data['values'] if 'values' in actual_data else []
#             except Exception as e:
#                 print(f"Error fetching actual values: {str(e)}")
#                 return []
        
#         actual_values = get_actual_values()
        
#         # 모델 평가 함수
#         def evaluate_model(endpoint_name):
#             try:
#                 response = sagemaker_runtime.invoke_endpoint(
#                     EndpointName=endpoint_name,
#                     ContentType='application/json',
#                     Body=json.dumps({"instances": [eval_instance]})
#                 )
                
#                 # 응답 처리
#                 predicted_result = json.loads(response['Body'].read().decode('utf-8'))
#                 predicted_values = predicted_result[0]['quantiles']['0.5']  # 중간값(50% 확률)의 예측값
                
#                 # MAE(Mean Absolute Error) 계산
#                 if len(predicted_values) > 0 and len(actual_values) > 0:
#                     mae = np.mean(np.abs(np.array(predicted_values) - np.array(actual_values[-len(predicted_values):])))
#                 else:
#                     mae = None
                
#                 return mae, predicted_values
            
#             except Exception as e:
#                 print(f"Error evaluating model {endpoint_name}: {str(e)}")
#                 return None, None
        
#         # 새 모델을 평가할 때 사용하는 엔드포인트 이름
#         new_model_endpoint_name = f'{company}-new-forecasting-endpoint'
#         create_endpoint(model_name, endpoint_config_name, new_model_endpoint_name)
        
#         # 새 모델과 현재 모델 평가
#         new_model_mae, new_model_predictions = evaluate_model(new_model_endpoint_name)
#         current_model_mae, current_model_predictions = evaluate_model(current_model_endpoint_name)
        
#         # 성능 비교 및 모델 결정
#         if new_model_mae is not None and (current_model_mae is None or new_model_mae < current_model_mae):
#             chosen_endpoint = new_model_endpoint_name
#             best_mae = new_model_mae
#         else:
#             chosen_endpoint = current_model_endpoint_name
#             best_mae = current_model_mae

#         print(json.dumps({
#             "selected_endpoint": chosen_endpoint,
#             "best_mae": best_mae,
#             "new_model_mae": new_model_mae,
#             "current_model_mae": current_model_mae,
#             "new_model_predictions": new_model_predictions,
#             "current_model_predictions": current_model_predictions
#         }))
    
    # # 결과를 반환
    # return {
    #     "statusCode": 200,
    #     "body": json.dumps({
    #         "selected_endpoint": chosen_endpoint,
    #         "best_mae": best_mae,
    #         "new_model_mae": new_model_mae,
    #         "current_model_mae": current_model_mae,
    #         "new_model_predictions": new_model_predictions,
    #         "current_model_predictions": current_model_predictions
    #     })
    # }

import boto3
import json
import os
import datetime
from datetime import datetime, timedelta

def handler(event, context):
    sagemaker_runtime = boto3.client('sagemaker-runtime')
    sagemaker = boto3.client('sagemaker')
    s3 = boto3.client('s3')
    
    bucket_name = os.environ['BUCKET_NAME']
    role_arn = os.environ['SAGEMAKER_ROLE']
    companies = event['companies']
    # training_job_names = event['TraingJobNames']
    
    
    def create_model(model_name, training_job_name, model_artifact, image_uri):
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
        
        # 엔드포인트 구성 생성
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

        # 엔드포인트 생성
        response = sagemaker.create_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=endpoint_config_name
        )

    def calculate_mae(predicted_values, actual_values):
        if len(predicted_values) == 0 or len(actual_values) == 0:
            return None
        
        if len(predicted_values) > len(actual_values):
            predicted_values = predicted_values[:len(actual_values)]
        
        # MAE 계산
        absolute_errors = [abs(p - a) for p, a in zip(predicted_values, actual_values[-len(predicted_values):])]
        mae = sum(absolute_errors) / len(absolute_errors)
        return mae

    for company in companies:
        
        today_date = datetime.now().strftime("%Y-%m-%d")
        
        
        yesterday = datetime.now() - timedelta(days=1)
        yester_date = yesterday.strftime("%Y-%m-%d")
        training_job_name = f'ESIATrainingJob-{company}-{today_date}215'
        
        # SageMaker 엔드포인트 이름
        current_model_endpoint_name = f'{company}-forecasting-endpoint'
        current_model_name = f'{company}-deepAR-{yester_date}'
        endpoint_config_name = f'{company}-endpoint-config'
        
        
        
        create_model(current_model_name, training_job_name, endpoint_config_name, current_model_endpoint_name)
        create_endpoint(current_model_name, endpoint_config_name, current_model_endpoint_name)
        
        # 오늘 날짜
        today_date_time = datetime.now().strftime("%Y-%m-%dT00:00:00")
        
        
        # 평가 데이터 생성 (예시)
        eval_instance = {
            "start": today_date_time,
            "target": []
            # "dynamic_features": []
        }
        
        # 평가할 데이터 가져오기
        def get_actual_values():
            try:
                # 예시로 실제 값을 빈 리스트로 설정
                s3_key = f'actual_data/{company}/{today_date}.json'
                response = s3.get_object(Bucket=bucket_name, Key=s3_key)
                actual_data = json.loads(response['Body'].read().decode('utf-8'))
                return actual_data['values'] if 'values' in actual_data else []
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
                    Body=json.dumps({"instances": [eval_instance]})
                )
                
                # 응답 처리
                predicted_result = json.loads(response['Body'].read().decode('utf-8'))
                predicted_values = predicted_result[0]['quantiles']['0.5']  # 중간값(50% 확률)의 예측값
                
                # MAE 계산
                mae = calculate_mae(predicted_values, actual_values) if len(predicted_values) > 0 else None
                
                return mae, predicted_values
            
            except Exception as e:
                print(f"Error evaluating model {endpoint_name}: {str(e)}")
                return None, None
        
        # 새 모델을 평가할 때 사용하는 엔드포인트 이름
        new_model_endpoint_name = f'{company}-new-forecasting-endpoint'
        new_model_name = f'{company}-deepAR-{today_date}'
        create_model(new_model_name, training_job_name, endpoint_config_name, new_model_endpoint_name)
        create_endpoint(new_model_name, endpoint_config_name, new_model_endpoint_name)
        
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

