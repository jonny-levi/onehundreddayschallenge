variable "region" {
  type        = string
  description = "The region of the S3 bucket"
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}

variable "aws_s3_bucket_name" {
  type        = string
  description = "A unique name of the S3 bucket"
}
