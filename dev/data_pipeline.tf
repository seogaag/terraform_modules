# ## DATA STORAGE
# module "lambda_stock_data_storage" {
#   source = "../modules/lambda"
#   bucket_name_raw = "esia-stock-raw"
#   lambda_function_name = "stock_price_collector"
#   api_key = "WVNLKV1T1O1GZ7ZG"
#   symbols = "AAPL,GOOGL,AMZN,TSLA"
# }

# ## DATA ETL
# module "glue" {
#   source             = "../modules/glue"
#   database_name      = "esia_database"
#   table_name         = "esia_glue_table"
#   s3_data_location   = module.lambda_stock_data_storage.bucket_name
#   crawler_name       = "esia_crawler"
#   s3_target_path     = "s3://${module.lambda_stock_data_storage.bucket_name_raw}/"
#   bucket_name_processed = "esia-stock-processed"
#   bucket_name_gluescripts = "esia-stock-gluescripts"
#   crawler_schedule   = "cron(0 12 * * ? *)"
#   script_location    = "s3://${bucket_name_gluescripts}/scripts/etl_script.py"
#   job_name           = "esia_etl_job"
#   max_capacity       = 2
#   columns_json       = jsonencode([
#     {
#       "name" = "timestamp"
#       "type" = "string"
#     },
#     {
#       "name" = "open"
#       "type" = "double"
#     },
#     {
#       "name" = "high"
#       "type" = "double"
#     },
#     {
#       "name" = "low"
#       "type" = "double"
#     },
#     {
#       "name" = "close"
#       "type" = "double"
#     },
#     {
#       "name" = "volume"
#       "type" = "bigint"
#     }
#   ])
# }

