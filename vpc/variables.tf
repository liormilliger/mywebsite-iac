# variable "vpc_name" {
#   description = "Your vpc name"
#   type        = string
# }

# variable "availability_zone" {
#   description = "Availability zone list"
#   type        = list(string)
# }

# variable "az_name" {
#   description = "Availability zone name list"
#   type        = list(string)
# }


variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

