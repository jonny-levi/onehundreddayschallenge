resource "aws_ecr_repository" "foo" {
  region               = var.ecr_region
  name                 = var.ecr_name
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.default_tags
}
