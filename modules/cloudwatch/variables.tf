variable "region" {
  description = "CloudWatch region"
  type        = string

}
variable "ec2_instance_id" {
  type = list(string)
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}
