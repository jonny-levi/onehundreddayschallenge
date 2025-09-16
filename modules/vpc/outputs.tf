output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpn_name" {
  value = aws_vpc.main.tags
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
