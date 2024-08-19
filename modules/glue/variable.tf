variable "service" {
  type = string
  default = "esia"
}

variable "database_name" {
  description = "The name of the Glue database."
  type        = string
}

variable "table_name" {
  description = "The name of the Glue table."
  type        = string
}

variable "s3_data_location" {
  description = "S3 location where data is stored."
  type        = string
}

variable "crawler_name" {
  description = "The name of the Glue crawler."
  type        = string
}

variable "s3_target_path" {
  description = "S3 path that the crawler will scan."
  type        = string
}

variable "crawler_schedule" {
  description = "The schedule for the Glue crawler in cron format."
  type        = string
}

variable "script_location" {
  description = "S3 location of the Glue ETL script."
  type        = string
}

variable "job_name" {
  description = "The name of the Glue ETL job."
  type        = string
}

variable "max_capacity" {
  description = "The maximum capacity for the Glue job."
  type        = number
}

variable "columns_json" {
  description = "JSON string of columns for the Glue table."
  type        = string
}


variable "bucket_name_processed" {
  type = string
}

variable "bucket_name_gluescripts" {
  type = string
}

variable "glue_s3_resource_arns" {
  type = list(string)
}

variable "glue_job_default_arguments" {
  type = map(string)
  default = {
    "--S3_SOURCE_PATH"      = "s3://esia-stock-raw/"
    "--S3_DESTINATION_PATH" = "s3://esia-stock-processed/"
  }
}