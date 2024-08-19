resource "aws_s3_bucket" "sagemaker_bucket" {
  bucket = "${var.service}-sagemaker-bucket"
}