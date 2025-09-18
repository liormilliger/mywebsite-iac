module "vpc" {
    source = "./vpc"
    cluster_name = var.cluster_name
    vpc_name = var.vpc_name
    cluster_version = var.cluster_version
    private_subnet_cidrs = var.private_subnet_cidrs
    public_subnet_cidrs = var.public_subnet_cidrs
    vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
    source = "./eks"
    cluster_name = var.cluster_name
    max_size = var.max_size
    node_name = var.node_name    
    capacity_type = var.capacity_type
    EbsCredSecret = var.EbsCredSecret
    REGION = var.REGION
    ACCOUNT = var.ACCOUNT
    instance_types = var.instance_types
    node_group_name = var.node_group_name
    cluster_version = var.cluster_version
    CredSecret = var.CredSecret
    desired_size = var.desired_size
        # Pass subnet IDs from the vpc-network module's outputs
    private_subnet_ids = module.vpc.private_subnet_ids
    public_subnet_ids = module.vpc.public_subnet_ids

}

module "argocd" {
  source                 = "./argocd"
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
    # REMOVED kubectl = kubectl
  }
  
  depends_on = [module.eks]
}

module "aws_load_balancer_controller" {
  source = "./lb-controller"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id

  providers = {
    helm = helm.eks
  }

  depends_on = [module.eks]
}


