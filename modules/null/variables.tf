variable "region" {
  type        = string
  description = "The region where to create the resouce"
}

variable "ecr_repo_url" {
  type        = string
  description = "the repo url of the ecr"
}

variable "github_url_containing_dockerfile" {
  type        = string
  description = "The github repo containing the dockerfile to be clone"
}

variable "image_name" {
  type        = string
  description = "Docker image name"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "github_repo_folder_name" {
  type        = string
  description = "The folder name of the cloned github"
}
