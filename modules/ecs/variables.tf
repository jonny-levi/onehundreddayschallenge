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
