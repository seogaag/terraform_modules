# provider "aws" {
#   region = "ap-south-1"
# }


# ## destroy
# # aws s3 rm s3://esia-stock-raw --recursive

# locals {
#   service = "esia"
# }

# ## DATA STORAGE
# resource "aws_s3_bucket" "s3_stock" {
#   bucket = "esia-stock"
# }

# # module "lambda_stock_data_raw" {
# #   source = "../modules/lambda"

# #   service = "esia-raw"
# #   bucket_arn = aws_s3_bucket.s3_stock.arn

# #   lambda_function_name = "pre_data"
# #   lambda_env = {}

# #   memory_size = 256
# #   timeout = 60
# # }

# module "lambda_stock_data_storage" {
#   source = "../modules/lambda"

#   # service = "esia"
#   service = local.service
#   bucket_arn = aws_s3_bucket.s3_stock.arn

#   lambda_function_name = "stock_collector"
#   lambda_env = {
#     BUCKET_NAME = aws_s3_bucket.s3_stock.bucket
#     API_KEY = "WVNLKV1T1O1GZ7ZG"
#     SYMBOLS  = "AAPL,GOOGL,AMZN,TSLA,IBM"
#   }

#   memory_size = 256
#   timeout = 15
# }

# module "daily_raw_cloudwatch" {
#   source = "../modules/cloudwatch_event"

#   service = local.service
#   cloudwatch_schedule = "rate(1 day)"
#   lambda_function_name = module.lambda_stock_data_storage.lambda_function_name
#   lambda_function_arn = module.lambda_stock_data_storage.lambda_function_arn
# }

# # ########
# # cd source
# # mkdir {lambda_function_name}
# # cd {lambda_function_name}
# # cp ../lambda_function.py .
# # pip install requests -t .
# # pip install urllib3==1.26.7 -t .
# # ~~
# # zip -r ../{lambda_function_name} .
# # #########


# # ## DATA ETL
# # module "glue" {
# #   source             = "../modules/glue"
# #   database_name      = "esia_database"
# #   table_name         = "esia_glue_table"
# #   s3_data_location   = module.lambda_stock_data_storage.bucket_name
# #   crawler_name       = "esia_crawler"
# #   s3_target_path     = "s3://${module.lambda_stock_data_storage.bucket_name}/"
# #   bucket_name_processed = "esia-stock-processed"
# #   bucket_name_gluescripts = "esia-stock-gluescripts"
# #   crawler_schedule   = "cron(0 12 * * ? *)"
# #   script_location    = "s3://esia-stock-raw/scripts/etl_script.py"
# #   job_name           = "esia_etl_job"
# #   max_capacity       = 2
# #   columns_json       = jsonencode([
# #     {
# #       "name" = "timestamp"
# #       "type" = "string"
# #     },
# #     {
# #       "name" = "open"
# #       "type" = "double"
# #     },
# #     {
# #       "name" = "high"
# #       "type" = "double"
# #     },
# #     {
# #       "name" = "low"
# #       "type" = "double"
# #     },
# #     {
# #       "name" = "close"
# #       "type" = "double"
# #     },
# #     {
# #       "name" = "volume"
# #       "type" = "bigint"
# #     }
# #   ])

# #   glue_s3_resource_arns = [
# #     # "arn:aws:s3:::stock-data-*",
# #     "arn:aws:s3:::esia-stock-raw*",
# #     "arn:aws:s3:::esia-stock-processed*",
# #     "arn:aws:s3:::esia-stock-gluescripts*" # ,
# #     # "arn:aws:s3:::analysis-results-*"
# #   ]
# #   # for_each = toset(["AAPL","GOOGL","AMZN","TSLA","IBM"])
# #   glue_job_default_arguments = {
# #     # "--S3_SOURCE_PATH"      = "s3://${module.lambda_stock_data_storage.bucket_name}/AAPL/"
# #     # "--S3_DESTINATION_PATH" = "s3://esia-stock-processed/AAPL/"
# #     "--SOURCE_S3_BUCKET"      = "${module.lambda_stock_data_storage.bucket_name}"
# #     "--SOURCE_S3_PREFIX"      = "AAPL/"
# #     "--DEST_S3_BUCKET"      = "esia-stock-processed"
# #     "--DEST_S3_PREFIX"      = "AAPL/"
# #     "--JOB_NAME"            = "esia-etl-job"
# #   }
  
# # }

# # # [
# # #   "arn:aws:s3:::stock-data-*",
# # #   "arn:aws:s3:::raw-stock-data-*",
# # #   "arn:aws:s3:::processed-stock-data-*",
# # #   "arn:aws:s3:::glue-scripts-*",
# # #   "arn:aws:s3:::analysis-results-*"
# # # ]
# ##################

# ## SAGEMAKER
module "sagemaker" {
  source = "../modules/sagemaker"

  service = "esia"

  # s3_key = "script/data_processing.py"
  # s3_sourcepath = "../source/data_processing.py"
  # image_uri = "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-scikit-learn:1.0-1-cpu-py3"
  # container_entrypoint = [ "python3" ]
  # container_arguments = [ "../source/data_processing.py" ]

  domain_vpc_id = module.vpc.vpc_id
  domain_subnet_ids = [ module.vpc.sub_pub_a_id, module.vpc.sub_pub_c_id ]

  depends_on = [ module.vpc ]
}
