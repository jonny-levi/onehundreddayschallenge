module "vpc_creation" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

}
module "ec2_creation" {
  source          = "./modules/ec2"
  private_subnets = module.vpc_creation.private_subnet_ids
  public_subnets  = module.vpc_creation.public_subnet_ids
  vpc_id          = module.vpc_creation.vpc_id
  user_data       = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y stress -y
    # Run stress for 5 minutes with 2 CPU workers
    stress --cpu 2 --timeout 1200
  EOT
  ec2_count       = 3
  depends_on      = [module.vpc_creation]
}

module "s3" {
  source = "./modules/s3"
  region = var.region
}

module "cloudwatch" {
  source          = "./modules/cloudwatch"
  region          = var.region
  ec2_instance_id = module.ec2_creation.ec2_instance_id
  depends_on      = [module.ec2_creation]
}

module "ecs" {
  source                      = "./modules/ecs"
  task_definition_family_name = "telegram-bot-service"
  ecs_image                   = "docker.io/library/ubuntu:latest"
  ecs_cluster_name            = "tg-bot-cluster"
  ecs_sevice_name             = "TGBotSVC"
}
