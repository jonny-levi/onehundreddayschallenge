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
}

module "s3" {
  source = "./modules/s3"
  region = var.region
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

