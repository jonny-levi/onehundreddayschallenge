resource "aws_s3_bucket" "example" {
  bucket = var.aws_s3_bucket_name
  region = var.region
  tags   = var.default_tags
}
