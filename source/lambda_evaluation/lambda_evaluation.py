import boto3
import json
import os
from datetime import datetime, timedelta
import time
from botocore.exceptions import ClientError

def handler(event, context):
    sagemaker_runtime = boto3.client('sagemaker-runtime')
    sagemaker = boto3.client('sagemaker')
    s3 = boto3.client('s3')
    
    bucket_name = os.environ['BUCKET_NAME']
    role_arn = os.environ['SAGEMAKER_ROLE']
    companies = event['companies']
    
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
                time.sleep(30)
    
    def create_model(model_name, training_job_name, model_artifact, image_uri):
        if model_exists(sagemaker, model_name):
            print("Model exists... Skip creating")
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
        actual_values = actual_values.get('target')[0]
        absolute_errors = [abs(predicted_values - actual_values)]
        mae = sum(absolute_errors) / len(absolute_errors)
        return mae
    
    def get_eval_target_data(company):
        s3_key = f'processed/{company}/eval.json'
        try:
            response = s3.get_object(Bucket=bucket_name, Key=s3_key)
            file_content = response['Body'].read().decode('utf-8')
            eval_instances = json.loads(file_content)
            return eval_instances
        except Exception as e:
            print(f"Error fetching eval data: {str(e)}")
            return []
    
    def get_actual_values(company):
        try:
            s3_key = f'processed/{company}/eval.json'
            response = s3.get_object(Bucket=bucket_name, Key=s3_key)
            file_content = response['Body'].read().decode('utf-8')
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
    
    def evaluate_model(endpoint_name, eval_instance):
        try:
            response = sagemaker_runtime.invoke_endpoint(
                EndpointName=endpoint_name,
                ContentType='application/json',
                Body=json.dumps(eval_instance)
            )
            response_body = response['Body'].read().decode('utf-8')
            predicted_result = json.loads(response_body)
            predicted_values = predicted_result['predictions'][0]['mean'][0]
            return predicted_values
        except Exception as e:
            print(f"Error evaluating model {endpoint_name}: {str(e)}")
            return None
    
    def save_prediction_to_s3(company, prediction):
        s3_key = f'predictions/{company}/prediction-{datetime.now().strftime("%Y-%m-%d-%H-%M-%S")}.json'
        try:
            s3.put_object(Bucket=bucket_name, Key=s3_key, Body=json.dumps(prediction))
            print(f"Prediction for {company} saved to {s3_key}")
        except Exception as e:
            print(f"Error saving prediction to S3: {str(e)}")
    
    def get_best_model_info():
        try:
            s3_key = 'best_model_info.json'
            response = s3.get_object(Bucket=bucket_name, Key=s3_key)
            file_content = response['Body'].read().decode('utf-8')
            best_model_info = json.loads(file_content)
            return best_model_info
        except Exception as e:
            print(f"Error fetching best model info: {str(e)}")
            return None
    
    def update_best_model_info(new_best_model_info):
        s3_key = 'best_model_info.json'
        try:
            s3.put_object(Bucket=bucket_name, Key=s3_key, Body=json.dumps(new_best_model_info))
            print(f"Best model info updated to {s3_key}")
        except Exception as e:
            print(f"Error updating best model info: {str(e)}")
    
    for company in companies:
        yesterday = datetime.now() - timedelta(days=1)
        yester_date = yesterday.strftime("%Y-%m-%d")
        
        current_model_endpoint_name = f'{company}-forecasting-endpoint-{yester_date}'
        current_model_name = f'{company}-deepAR-{yester_date}'
        current_endpoint_config_name = f'{company}-endpoint-config-{yester_date}'
        current_training_job_name = f'ESIATrainingJob-{company}-{yester_date}'
        
        create_model(current_model_name, current_training_job_name, current_endpoint_config_name, current_model_endpoint_name)
        create_endpoint(current_model_name, current_endpoint_config_name, current_model_endpoint_name)

        eval_instance = {
            "instances": [
                {
                    "start": get_eval_target_data(company).get("start"),
                    "target": []    
                }
            ]
        }
        
        actual_values = get_actual_values(company)
        
        best_model_info = get_best_model_info()
        best_model_mae = best_model_info.get("best_mae") if best_model_info else float('inf')
        best_model_endpoint = best_model_info.get("best_model_endpoint") if best_model_info else None
        
        new_model_predictions = evaluate_model(current_model_endpoint_name, eval_instance)
        new_model_mae = calculate_mae(new_model_predictions, actual_values)
        
        if new_model_mae < best_model_mae:
            chosen_endpoint = current_model_endpoint_name
            best_mae = new_model_mae
            update_best_model_info({
                "best_model_endpoint": chosen_endpoint,
                "best_mae": best_mae
            })
        else:
            chosen_endpoint = best_model_endpoint
            best_mae = best_model_mae
        
        prediction = {
            "selected_endpoint": chosen_endpoint,
            "best_mae": best_mae,
            "new_model_mae": new_model_mae,
            "current_model_predictions": new_model_predictions
        }
        
        save_prediction_to_s3(company, prediction)
