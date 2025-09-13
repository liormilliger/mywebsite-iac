output "subnet_ids" {
  value = { for subnet in aws_subnet.us-east-subnets : subnet.availability_zone => subnet.id }
  description = "The IDs of the subnets in the us-east region."
}

output "VPC_ID" {
    description = "VPC id for liorm_portfolio"
    value = aws_vpc.liorm-portfolio.id
}

output "vpc_name" {
  description = "Your vpc name"
  value = var.vpc_name
}

output "availability_zone" {
  description = "Availability zone list"
  value = var.availability_zone
}

output "az_name" {
  description = "Availability zone name list"
  value = var.az_name
}