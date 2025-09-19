variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for your EKS cluster's Kubernetes API."
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  type        = string
}

variable "config_repo_url" {
  description = "URL to mywebsite-k8s github repo"
  type = string
}

variable config_repo_secret_name {
  description = "Secret name from aws secret manager"
  type = string
}
