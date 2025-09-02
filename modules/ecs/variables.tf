variable "task_definition_family_name" {
  type        = string
  description = "The Task Definition family name"

}
variable "ecs_image" {
  type        = string
  description = "The ecs image for the container"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "ecs_sevice_name" {
  type        = string
  description = "ECS service name"
}
variable "ecs_container_name" {
  type        = string
  description = "The ECS container name"
}

variable "ecs_containerport" {
  type        = number
  description = "The container port of the ecs"

}
variable "ecs_hostport" {
  type        = number
  description = "the ecs host port"
}

variable "vpc_public_subnet_cidrs" {
  type        = list(string)
  description = "The VPC public subnets"
}
