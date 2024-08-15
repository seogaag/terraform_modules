locals {
  columns = jsondecode(var.columns_json)
}

resource "aws_glue_catalog_database" "glue_catalog_database" {
  name = var.database_name
}

resource "aws_glue_catalog_table" "glue_catalog_table" {
  name          = var.table_name
  database_name = aws_glue_catalog_database.glue_catalog_database.name

  storage_descriptor {
    dynamic "columns" {
      for_each = local.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }

    location      = var.s3_data_location
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
  }
}

resource "aws_glue_crawler" "glue_crawler" {
  name          = var.crawler_name
  role          = aws_iam_role.glue_service_role.arn
  database_name = aws_glue_catalog_database.glue_catalog_database.name

  s3_target {
    path = var.s3_target_path
  }

  schedule = var.crawler_schedule
}

resource "aws_glue_job" "glue_job" {
  name     = var.job_name
  role_arn = aws_iam_role.glue_service_role.arn
  command {
    name            = "glueetl"
    script_location = var.script_location
    python_version  = "3"
  }
  max_capacity = var.max_capacity

  default_arguments = var.glue_job_default_arguments
  
  glue_version = "3.0"
}

