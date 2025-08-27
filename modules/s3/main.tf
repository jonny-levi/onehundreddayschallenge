resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"
  region = var.region

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
