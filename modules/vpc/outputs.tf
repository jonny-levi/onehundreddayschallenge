output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpn_name" {
  value = aws_vpc.main.tags
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}
