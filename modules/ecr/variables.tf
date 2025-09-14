variable "ecr_name" {
  type        = string
  description = "The ECR name"
}

variable "ecr_region" {
  type        = string
  description = "The ECR region"
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}
