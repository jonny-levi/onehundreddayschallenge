variable "eks_cluster_name" {
  type        = string
  description = "The EKS cluster name"
}

variable "eks_cluster_version" {
  type        = string
  description = "The EKS cluster version"
}

variable "eks_private_subnets" {
  type = list(string)

}
