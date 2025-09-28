terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

# Creates the namespace where ArgoCD's components will be installed.
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Installs the ArgoCD platform from the official Helm chart.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.51.2"
}

# Wait for CRDs to be registered
resource "time_sleep" "wait_for_crd_registration" {
  create_duration = "30s"
  depends_on      = [helm_release.argocd]
}

# Get Git secret from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "config-repo-private-sshkey" {
  secret_id = var.config-repo-secret-name
}

# Create Kubernetes Secret for ArgoCD repo access
resource "kubernetes_secret" "config_repo_ssh" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = var.config-repo-secret-name
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = var.config_repo_url
    # Decode the JSON from Secrets Manager and extract the key value
    sshPrivateKey = jsondecode(data.aws_secretsmanager_secret_version.config-repo-private-sshkey.secret_string)["config-repo-private-sshkey"] # <-- CHANGE THIS LINE
  }
}

# This creates the main "App of Apps" in ArgoCD.
resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "git@github.com:liormilliger/mywebsite-k8s.git"
        path           = "argocd-apps"
        targetRevision = "main"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    time_sleep.wait_for_crd_registration
  ]
}
