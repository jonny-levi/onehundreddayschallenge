module "vpc_creation" {
  # count                = var.vpc_module_creation ? 1 : 0
  source = "./modules/vpc"
  private_cidrs_to_az = [
    { cidr = "10.0.101.0/24", az = "us-east-1a" },
    { cidr = "10.0.102.0/24", az = "us-east-1b" }
  ]
  public_cidrs_to_az = [
    { cidr = "10.0.103.0/24", az = "us-east-1a" },
    { cidr = "10.0.104.0/24", az = "us-east-1b" }
  ]
  # public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  # private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  vpc_name     = "${var.project-name}-vpc"
  default_tags = var.default_tags
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
#   source             = "./modules/s3"
#   region             = var.region
#   aws_s3_bucket_name = var.s3_bucket_name
#   default_tags       = var.default_tags
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
  source       = "./modules/ecr"
  ecr_name     = "${var.project-name}-ecr"
  ecr_region   = var.region
  default_tags = var.default_tags
}

module "null" {
  source                           = "./modules/null"
  region                           = var.region
  ecr_repo_url                     = module.ecr_creation.ecr_repo_url
  image_name                       = "${var.project-name}-telegram"
  image_tag                        = var.image_tag
  github_url_containing_dockerfile = var.github_url_containing_dockerfile
  github_repo_folder_name          = "${var.project-name}-telegram-bot"
  default_tags                     = var.default_tags
}

# module "ecs" {
#   # count                       = var.ecs_module_creation ? 1 : 0
#   source                      = "./modules/ecs"
#   task_definition_family_name = "${var.project-name}-family"
#   ecs_image                   = "${module.ecr_creation.ecr_repo_url}:${var.image_tag}"
#   ecs_cluster_name            = "${var.project-name}-cluster"
#   ecs_sevice_name             = "${var.project-name}-service"
#   ecs_container_name          = "${var.project-name}-container"
#   ecs_container_count         = 1
#   ecs_containerport           = 80
#   ecs_hostport                = 80
#   vpc_public_subnet_cidrs     = module.vpc_creation.public_subnet_ids
#   vpc_id                      = module.vpc_creation.vpc_id
#   security_group_name         = "${var.project-name}-sg"
#   default_tags                = var.default_tags
#   container_cpu               = 1024
#   container_memory            = 2048
#   ecs_environment = {
#     BOT_TOKEN = "8076237859:AAG6RQsqQ1aQdSQNsJonhVqQb5a5muZqWys"
#   }
# }

# module "eks" {
#   source                             = "./modules/eks"
#   eks_cluster_name                   = "${var.project-name}-cluster"
#   eks_cluster_version                = "1.31" #1.32 #1.33
#   eks_private_subnets                = module.vpc_creation.private_subnet_ids
#   max_number_of_ec2eks_instances     = 2
#   min_number_of_ec2eks_instances     = 1
#   desired_number_of_ec2eks_instances = 2
#   node_group_name                    = "${var.project-name}-node-group"
#   default_tags                       = var.default_tags
# }
