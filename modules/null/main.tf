resource "null_resource" "docker_build_and_push" {
  depends_on = [var.ecr_repo_url]

  provisioner "local-exec" {
    command = <<EOT

      # clone the github repo containing the Dockerfile
      git clone ${var.github_url_containing_dockerfile} ${var.github_repo_folder_name}

      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${var.region} \
        | docker login --username AWS --password-stdin ${var.ecr_repo_url}

      # Build the Docker image
      docker build -t ${var.image_name}:${var.image_tag} ./${var.github_repo_folder_name}

      # Tag the image for ECR
      docker tag ${var.image_name}:${var.image_tag} ${var.ecr_repo_url}:${var.image_tag}

      # Push to ECR
      docker push ${var.ecr_repo_url}:${var.image_tag}
    EOT
  }
}

data "aws_caller_identity" "current" {}
