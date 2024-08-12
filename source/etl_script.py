import sys
import boto3
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.transforms import *
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_timestamp

# 스크립트에서 필요한 인자를 가져옵니다.
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_SOURCE_PATH', 'S3_DESTINATION_PATH'])

# Spark 및 Glue 컨텍스트 생성
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Glue 작업 생성
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# S3에서 데이터 읽기
source_df = spark.read.format("csv").option("header", "true").load(args['S3_SOURCE_PATH'])

# 데이터 변환 작업
transformed_df = source_df.withColumn("timestamp", to_timestamp(col("timestamp"))) \
                           .withColumn("open", col("open").cast("double")) \
                           .withColumn("high", col("high").cast("double")) \
                           .withColumn("low", col("low").cast("double")) \
                           .withColumn("close", col("close").cast("double")) \
                           .withColumn("volume", col("volume").cast("bigint"))

# 변환된 데이터를 S3에 저장
transformed_df.write.mode("overwrite").format("parquet").save(args['S3_DESTINATION_PATH'])

# Glue 작업 완료
job.commit()
