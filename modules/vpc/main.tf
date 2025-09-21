resource "aws_vpc" "main" {
  cidr_block       = var.aws_vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
# resource "aws_subnet" "public" {
#   count      = length(var.public_subnet_cidrs)
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.public_subnet_cidrs[count.index]
#   tags       = { Name = "public-${count.index + 1}" }
# }
resource "aws_subnet" "public" {
  for_each = { for s in var.public_cidrs_to_az : s.cidr => s }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = try(each.value.az, data.aws_availability_zones.available.names[each.value.index])

  tags = merge(var.default_tags, {
    Name = "public-subnet-${try(each.value.az, data.aws_availability_zones.available.names[each.value.index])}"
  })
}

# resource "aws_subnet" "private" {
#   count                   = length(var.private_subnet_cidrs)
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.private_subnet_cidrs[count.index]
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "private-subnet-${count.index + 1}"
#   }
# }

resource "aws_subnet" "private" {
  for_each = { for s in var.private_cidrs_to_az : s.cidr => s }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = try(each.value.az, data.aws_availability_zones.available.names[each.value.index])

  tags = merge(var.default_tags, {
    Name = "private-subnet-${try(each.value.az, data.aws_availability_zones.available.names[each.value.index])}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.default_tags, {
    Name = "public-rt"
  })
}
resource "aws_route_table_association" "public" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route tables for PRIVATE subnets -> NAT Gateway in same AZ
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = one([
      for k, nat in aws_nat_gateway.example : nat.id
      if nat.subnet_id == one([
        for s in aws_subnet.public : s.id if s.availability_zone == each.value.availability_zone
      ])
    ])
  }

  tags = merge(var.default_tags, {
    Name = "private-rt-${each.key}"
  })
}

# Associate each private subnet with its own route table
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"
  # vpc      = true
  tags = merge(var.default_tags, {
    Name = "eip-nat-${each.key}"
  })

}

resource "aws_nat_gateway" "example" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.default_tags, {
    Name = "nat-gateway-${each.key}"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
