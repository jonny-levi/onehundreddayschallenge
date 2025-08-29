resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-jonathan-levi10010101"
  region = var.region
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
