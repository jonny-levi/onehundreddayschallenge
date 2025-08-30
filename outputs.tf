output "aws_vpc" {
  value = module.vpc_creation.vpc_id
}

output "ec2_instance_id" {
  value = module.ec2_creation.ec2_instance_id[*]
}

output "aws_s3_bucket" {
  value = module.s3.aws_s3
}

output "cloudwatch" {
  value = module.cloudwatch.aws_cloudwatch_dashboard
}

