output "docker_image" {
  value = null_resource.docker_build_and_push.id
}


output "docker_image_name" {
  value = "${var.ecr_repo_url}/${var.image_name}:${var.image_tag}"
}
