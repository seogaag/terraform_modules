# 처리된 데이터 저장용 S3 버킷
resource "aws_s3_bucket" "stock_processed_bucket" {
  bucket = var.bucket_name_processed
}

# ETL 스크립트 저장용 S3 버킷
resource "aws_s3_bucket" "stock_scripts_bucket" {
  bucket = var.bucket_name_gluescripts
  acl = "private"
}

resource "aws_s3_bucket_object" "etl_script" {
  bucket = aws_s3_bucket.stock_scripts_bucket.bucket
  key    = "scripts/etl_script.py"
  source = "source/etl_script.py" # 로컬 경로
  acl    = "private"
}
