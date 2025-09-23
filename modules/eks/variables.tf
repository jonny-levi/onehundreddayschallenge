variable "eks_cluster_name" {
  type        = string
  description = "The EKS cluster name"
}

variable "eks_cluster_version" {
  type        = string
  description = "The EKS cluster version"
}

variable "eks_private_subnets" {
  type        = list(string)
  description = "Private subnets IDs for the eks cluster"
}

variable "desired_number_of_ec2eks_instances" {
  type        = number
  description = "The number of the desired size of ec2 instances eks will run"
}

variable "min_number_of_ec2eks_instances" {
  type        = number
  description = "The minimum number of ec2 instances eks will run"
}
variable "max_number_of_ec2eks_instances" {
  type        = number
  description = "The maximum number of ec2 instances eks will run"
}

variable "node_group_name" {
  type        = string
  description = "The node group name"
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}

variable "vpc_id" {
  type = string
}
