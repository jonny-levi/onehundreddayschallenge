variable "aws_instance_name" {
  type    = string
  default = "test"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS will be deployed"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets for EKS"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets for load balancers, etc."
}

variable "user_data" {
  type        = string
  description = "User data script to configure EC2 instance"
  default     = null
}
