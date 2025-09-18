# This data source gets a list of available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# This assumes your aws_vpc resource is in another file in this module (e.g., vpc.tf)
# If it's not, you'll need to include its definition here.
# resource "aws_vpc" "liorm_vpc" { ... }

resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.liorm_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  
  # Dynamically assigns an availability zone to each subnet
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                      = "liorm-private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.ioio/role/internal-elb"         = "1" 
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.liorm_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  # Dynamically assigns an availability zone to each subnet
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                      = "liorm-public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}