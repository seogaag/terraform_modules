import sagemaker
import boto3
from sagemaker.estimator import Estimator
from sagemaker.predictor import Predictor
from sagemaker.serializers import JSONSerializer
from sagemaker.deserializers import JSONDeserializer
from sagemaker import get_execution_role

# SageMaker 및 AWS 설정
role = get_execution_role()
session = sagemaker.Session()
region = session.boto_region_name


bucket_name = 'esia-stock'
s3_data_prefix = 'AAPL/'
s3_data_path = f's3://{bucket_name}/{s3_data_prefix}'
output_path = f's3://{bucket_name}/deepar-output/'

# DeepAR 컨테이너 이미지 설정
image_name = sagemaker.image_uris.retrieve('forecasting-deepar', region)

# DeepAR 모델 설정
estimator = Estimator(
    image_uri=image_name,
    role=role,
    instance_count=1,
    instance_type='ml.c4.xlarge',
    output_path=output_path,
    sagemaker_session=session
)

# 하이퍼파라미터 설정
estimator.set_hyperparameters(
    time_freq='H',  # 시계열 빈도 (시간)
    epochs=20,
    early_stopping_patience=10,
    mini_batch_size=32,
    learning_rate=0.001,
    context_length=48,  # 예측에 사용할 이전 데이터 포인트 수
    prediction_length=24,  # 예측할 시간 간격 수
    num_layers=3,
    num_cells=40,
    cell_type='lstm'
)

# 모델 훈련
estimator.fit({'train': train_s3_path, 'test': test_s3_path})

# 모델 배포
predictor = estimator.deploy(
    initial_instance_count=1,
    instance_type='ml.m4.xlarge',
    serializer=JSONSerializer(),
    deserializer=JSONDeserializer()
)

# 예측 수행
predictor_input = {
    "instances": [test_series]
}

predictions = predictor.predict(predictor_input)
print(predictions)

# 모델 배포 종료
predictor.delete_endpoint()
