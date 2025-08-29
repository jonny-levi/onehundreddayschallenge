output "aws_vpc" {
  value = module.vpc_creation
}

output "ec2" {
  value = module.ec2_creation.aws_instance
}

output "aws_s3_bucket" {
  value = module.s3.aws_s3
}

output "cloudwatch" {
  value = module.cloudwatch
}

