resource "null_resource" "docker_build_and_push" {
  depends_on = [aws_ecr_repository.telegram_bot]

  provisioner "local-exec" {
    command = <<EOT
      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${var.region} \
        | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com

      # Build the Docker image
      docker build -t telegram-bot:latest ./telegram-bot

      # Tag the image for ECR
      docker tag telegram-bot:latest ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.telegram_bot.name}:latest

      # Push to ECR
      docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.telegram_bot.name}:latest
    EOT
  }
}

data "aws_caller_identity" "current" {}
