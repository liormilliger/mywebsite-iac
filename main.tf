module "vpc" {
    source = "./vpc"
    cluster_name = var.cluster_name
    vpc_name = var.vpc_name
    cluster_version = var.cluster_version
}

module "eks" {
    source = "./eks"
    IAM_policies = var.IAM_policies
    subnets = var.subnets
    cluster_name = var.cluster_name
    node_type = var.node_type
    desired = var.desired
    max_size = var.max_size
    node_capacity = var.node_capacity
    node_name = var.node_name
    



    capacity_type = var.capacity_type
    EbsCredSecret = var.EbsCredSecret
    REGION = var.REGION
    ACCOUNT = var.ACCOUNT
    instance_types = var.instance_types
    node_name = var.node_name
    node_group_name = var.node_group_name
    max_size = var.max_size
    cluster_version = var.cluster_version
    CredSecret = var.CredSecret
    desired_size = var.desired_size
        # Pass subnet IDs from the vpc-network module's outputs
    private_subnet_ids = module.vpc-network.private_subnet_ids
    public_subnet_ids = module.vpc-network.public_subnet_ids

}