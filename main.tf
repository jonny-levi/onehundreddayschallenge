module "vpc_creation" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

}


module "ecs" {
  source                      = "./modules/ecs"
  task_definition_family_name = "telegram-bot-service"
  ecs_image                   = "docker.io/library/ubuntu:latest"
  ecs_cluster_name            = "tg-bot-cluster"
  ecs_sevice_name             = "TGBotSVC"
  ecs_container_name          = "Telegram-money-container"
  ecs_containerport           = 80
  ecs_hostport                = 80
  vpc_public_subnet_cidrs     = module.vpc_creation.public_subnet_ids
}
