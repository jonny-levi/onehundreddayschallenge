module "vpc_creation" {
  # count                = var.vpc_module_creation ? 1 : 0
  source               = "./modules/vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  vpc_name             = "${var.project-name}-vpc"
}

# module "ec2_creation" {
#   # count           = var.ec2_module_creation ? 1 : 0
#   source          = "./modules/ec2"
#   private_subnets = module.vpc_creation.private_subnet_ids
#   public_subnets  = module.vpc_creation.public_subnet_ids
#   vpc_id          = module.vpc_creation.vpc_id
#   user_data       = <<-EOT
#     #!/bin/bash
#     yum update -y
#     yum install -y stress -y
#     # Run stress for 5 minutes with 2 CPU workers
#     stress --cpu 2 --timeout 1200
#   EOT
#   ec2_count       = 3
#   depends_on      = [module.vpc_creation]
# }

# module "s3" {
#   # count  = var.s3_module_creation ? 1 : 0
#   source = "./modules/s3"
#   region = var.region
# }

# module "cloudwatch" {
#   # count           = var.cloudwatch_module_creation ? 1 : 0
#   source          = "./modules/cloudwatch"
#   region          = var.region
#   ec2_instance_id = module.ec2_creation.ec2_instance_id
#   depends_on      = [module.ec2_creation]
# }

# module "codepipeline" {
#   source              = "./modules/codepipeline"
#   codepipeline-region = var.region
#   codepipeline-name   = "test-pipeline01"
# }

module "ecr_creation" {
  source     = "./modules/ecr"
  ecr_name   = "${var.project-name}-ecr"
  ecr_region = var.region
}

module "ecs" {
  # count                       = var.ecs_module_creation ? 1 : 0
  source                      = "./modules/ecs"
  task_definition_family_name = "${var.project-name}-family"
  ecs_image                   = var.ecs_image
  ecs_cluster_name            = "${var.project-name}-cluster"
  ecs_sevice_name             = "${var.project-name}-service"
  ecs_container_name          = "${var.project-name}-container"
  ecs_containerport           = 80
  ecs_hostport                = 80
  vpc_public_subnet_cidrs     = module.vpc_creation.public_subnet_ids
}
