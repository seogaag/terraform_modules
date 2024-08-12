output "glue_database_name" {
  value = aws_glue_catalog_database.this.name
}

output "glue_table_name" {
  value = aws_glue_catalog_table.this.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.this.name
}

output "glue_job_name" {
  value = aws_glue_job.this.name
}

output "bucket_name_processed" {
  value = aws_s3_bucket.processed_stock_data_bucket.bucket
}

output "bucket_name_gluescripts" {
  value = aws_s3_bucket.glue_scripts_bucket.bucket
}
