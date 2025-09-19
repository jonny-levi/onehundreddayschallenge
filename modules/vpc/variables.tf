variable "vpc_name" {
  type        = string
  description = "The VPC name"
}

variable "aws_vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) <= length(data.aws_availability_zones.available.names)
    error_message = "You cannot specify more private subnets than available AZs in this region."
  }
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}
