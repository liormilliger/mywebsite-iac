terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }

  backend "s3" {
    bucket = "liorm-portfolio-tfstate"
    key    = "mywebsite-tfstate/terraform.tfstate"
    region = "us-east-1"

  }
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

# provider "helm" {
#   kubernetes {
#     config_path            = "~/.kube/config"
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_ca)
#   }
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_ca)
#   token                  = data.aws_eks_cluster_auth.cluster.token

# }

# provider "kubectl" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_ca)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

# resource "null_resource" "update_kubeconfig" {
#   # Ensures this runs after the EKS cluster has been created
#   depends_on = [module.eks]

#   provisioner "local-exec" {
#     command = "aws eks --region us-east-1 update-kubeconfig --name ${module.eks.cluster_name}"
#   }
# }