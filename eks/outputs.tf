output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server."
  value       = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster."
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}