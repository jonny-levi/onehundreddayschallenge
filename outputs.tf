output "aws_vpc" {
  value = module.vpc_creation.vpc_id
}

output "aws_vpc_name" {
  value = module.vpc_creation.vpn_name
}
output "ecr_repository_url" {
  value = module.ecr_creation.ecr_repo_url
}

# output "ecs_sevice_name" {
#   value = module.ecs.aws_ecs_service_bot_ip
# }

# output "ec2_instance_id" {
#   value = module.ec2_creation.ec2_instance_id[*]
# }

# output "aws_s3_bucket" {
#   value = module.s3.aws_s3
# }

# output "cloudwatch" {
#   value = module.cloudwatch.aws_cloudwatch_dashboard
# }

# output "null_resource" {
#   value = module.null.docker_image
# }

# output "docker_image_name" {
#   value = module.null.docker_image_name
# }
output "vpc_public_cidrs_to_az" {
  value = module.vpc_creation.public_subnet_ids
}

output "vpc_private_cidrs_to_az" {
  value = module.vpc_creation.private_subnet_ids
}
output "eks_cluster_ca" {
  value = module.eks.eks_cluster_ca
}

output "eks_config" {
  value     = module.eks.kubeconfig
  sensitive = true
}
