resource "aws_vpc" "liorm-portfolio" {
  cidr_block = "10.1.0.0/16"

  tags = {
    # Name = var.vpc_name
    Name = "mywebapp-vpc"
  }
}

resource "aws_subnet" "us-east-subnets" {
  for_each                = { for idx, az in var.availability_zone : idx => az }
  vpc_id                  = aws_vpc.liorm-portfolio.id
  cidr_block              = "10.1.${each.key + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = each.value
  tags = {
    Name = var.az_name[each.key]
  }
}

resource "aws_internet_gateway" "liorm" {
  vpc_id = aws_vpc.liorm-portfolio.id
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_route_table" "liorm" {
  vpc_id = aws_vpc.liorm-portfolio.id

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.liorm.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.liorm.id
}

resource "aws_route_table_association" "liorm-pub" {
  for_each        = aws_subnet.us-east-subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.liorm.id
}