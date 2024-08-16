import sys
import boto3
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession

# 필요한 인자들을 받아옵니다.
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'SOURCE_S3_BUCKET', 'SOURCE_S3_PREFIX', 'DEST_S3_BUCKET', 'DEST_S3_PREFIX'])

# Spark 및 Glue 컨텍스트를 설정합니다.
sc = SparkContext()
glueContext = GlueContext(sc)
spark = SparkSession.builder.config("spark.sql.parquet.compression.codec", "gzip").getOrCreate()
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 소스 데이터의 위치를 설정합니다.
source_path = f"s3://{args['SOURCE_S3_BUCKET']}/{args['SOURCE_S3_PREFIX']}"

# 데이터를 읽어옵니다.
data_frame = glueContext.create_dynamic_frame_from_options(
    connection_type="s3",
    connection_options={"paths": [source_path], "recurse": True},
    format="json"
)

# DynamicFrame을 DataFrame으로 변환합니다.
df = data_frame.toDF()

# 데이터 변환 작업 예제 (예: timestamp를 표준 형식으로 변환)
from pyspark.sql.functions import col, to_timestamp

df = df.withColumn("timestamp", to_timestamp(col("timestamp"), "yyyy-MM-dd HH:mm:ss"))

# 변환된 DataFrame을 다시 DynamicFrame으로 변환합니다.
transformed_dynamic_frame = glueContext.create_dynamic_frame_from_catalog(
    frame=df
)

# 변환된 데이터를 저장할 위치를 설정합니다.
dest_path = f"s3://{args['DEST_S3_BUCKET']}/{args['DEST_S3_PREFIX']}"

# 데이터를 S3에 저장합니다.
glueContext.write_dynamic_frame_from_options(
    frame=transformed_dynamic_frame,
    connection_type="s3",
    connection_options={"path": dest_path},
    format="json"
)

# ETL 작업을 완료합니다.
job.commit()
