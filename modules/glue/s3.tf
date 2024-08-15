# 처리된 데이터 저장용 S3 버킷
resource "aws_s3_bucket" "processed_bucket" {
  bucket = var.bucket_name_processed
}

# ETL 스크립트 저장용 S3 버킷
resource "aws_s3_bucket" "scripts_bucket" {
  bucket = var.bucket_name_gluescripts
}

resource "aws_s3_object" "etl_script" {
  bucket = aws_s3_bucket.scripts_bucket.bucket
  key    = "scripts/etl_script.py"
  source = "../source/etl_script.py" # 로컬 경로
}
