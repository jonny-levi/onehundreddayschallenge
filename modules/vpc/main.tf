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

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}
resource "aws_route_table_association" "public" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.example.id
}
