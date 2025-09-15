
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.liorm_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = "us-east-1a" # Example availability zone, adjust as needed
  tags = {
    Name = "liorm-private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.liorm_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = "us-east-1b" # Example availability zone, adjust as needed
  map_public_ip_on_launch = true
  tags = {
    Name = "liorm-public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
