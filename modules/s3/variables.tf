variable "region" {
  type        = string
  description = "The region of the S3 bucket"
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}
