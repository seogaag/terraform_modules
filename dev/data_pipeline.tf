## destroy
# aws s3 rm s3://esia-stock-raw --recursive

## DATA STORAGE

module "lambda_stock_data_storage" {
  source = "../modules/lambda"

  service = "esia"
  bucket_name = "esia-stock-raw"

  lambda_function_name = "stock_collector"
  lambda_env = {
    BUCKET_NAME = module.lambda_stock_data_storage.bucket_name
    API_KEY = "WVNLKV1T1O1GZ7ZG"
    SYMBOLS  = "AAPL,GOOGL,AMZN,TSLA,IBM"
  }

  cloudwatch_schedule = "rate(1 hour)"

  memory_size = 256
  timeout = 15
}

# ########
# cd source
# mkdir {lambda_function_name}
# cd {lambda_function_name}
# cp ../lambda_function.py .
# pip install requests -t .
# pip install urllib3==1.26.7 -t .
# ~~
# zip -r ../{lambda_function_name} .
# #########


## DATA ETL
module "glue" {
  source             = "../modules/glue"
  database_name      = "esia_database"
  table_name         = "esia_glue_table"
  s3_data_location   = module.lambda_stock_data_storage.bucket_name
  crawler_name       = "esia_crawler"
  s3_target_path     = "s3://${module.lambda_stock_data_storage.bucket_name}/"
  bucket_name_processed = "esia-stock-processed"
  bucket_name_gluescripts = "esia-stock-gluescripts"
  crawler_schedule   = "cron(0 12 * * ? *)"
  script_location    = "s3://esia-stock-gluescripts/scripts/etl_script.py"
  job_name           = "esia_etl_job"
  max_capacity       = 2
  columns_json       = jsonencode([
    {
      "name" = "timestamp"
      "type" = "string"
    },
    {
      "name" = "open"
      "type" = "double"
    },
    {
      "name" = "high"
      "type" = "double"
    },
    {
      "name" = "low"
      "type" = "double"
    },
    {
      "name" = "close"
      "type" = "double"
    },
    {
      "name" = "volume"
      "type" = "bigint"
    }
  ])

  glue_s3_resource_arns = [
    # "arn:aws:s3:::stock-data-*",
    "arn:aws:s3:::esia-stock-raw*",
    "arn:aws:s3:::esia-stock-processed*",
    "arn:aws:s3:::esia-stock-gluescripts*" # ,
    # "arn:aws:s3:::analysis-results-*"
  ]

  glue_job_default_arguments = {
    "--S3_SOURCE_PATH"      = "s3://esia-stock-raw/*"
    "--S3_DESTINATION_PATH" = "s3://esia-stock-processed/*"
  }
  
}

# [
#   "arn:aws:s3:::stock-data-*",
#   "arn:aws:s3:::raw-stock-data-*",
#   "arn:aws:s3:::processed-stock-data-*",
#   "arn:aws:s3:::glue-scripts-*",
#   "arn:aws:s3:::analysis-results-*"
# ]