variable "region" {
  type        = string
  description = "The region where all resources will be created"
  default     = "us-east-1"
}

variable "project-name" {
  type        = string
  description = "Project name to apply on all resources"
  default     = "jonathan-tf-tg-bot"
}
variable "default_tags" {
  type = map(string)
  default = {
    Project     = "TelegramBot"
    Environment = "dev"
    Owner       = "Jonathan"
  }
}
variable "vpc_module_creation" {
  type        = bool
  default     = true
  description = "True or False for module creation"
}

variable "ec2_module_creation" {
  type        = bool
  default     = false
  description = "True or False for module creation"
}

variable "s3_module_creation" {
  type        = bool
  default     = false
  description = "True or False for module creation"
}

variable "cloudwatch_module_creation" {
  type        = bool
  default     = false
  description = "True or False for module creation"
}

variable "ecs_module_creation" {
  type        = bool
  default     = false
  description = "True or False for module creation"
}

variable "ecs_image" {
  type        = string
  description = "The ECS image name"
  default     = "docker.io/library/ubuntu:latest"
}
variable "github_url_containing_dockerfile" {
  default = "https://github.com/jonny-levi/smart-bot-translator.git"
}
