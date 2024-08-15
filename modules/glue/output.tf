output "glue_database_name" {
  value = aws_glue_catalog_database.glue_catalog_database.name
}

output "glue_table_name" {
  value = aws_glue_catalog_table.glue_catalog_table.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.glue_crawler.name
}

output "glue_job_name" {
  value = aws_glue_job.glue_job.name
}

output "bucket_name_processed" {
  value = aws_s3_bucket.processed_bucket.bucket
}

output "bucket_name_gluescripts" {
  value = aws_s3_bucket.scripts_bucket.bucket
}
