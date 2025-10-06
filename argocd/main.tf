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

# Get Git secret from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "config-repo-private-sshkey" {
  secret_id = var.config-repo-secret-name
}

# Installs the ArgoCD platform from the official Helm chart.
# <<< CHANGE START: We now pass the repository config directly into the Helm release.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.51.2"

  values = [
    yamlencode({
      # This block configures repositories directly in ArgoCD's configmap and secrets.
      # The Helm chart will create the correctly labeled secret for you.
      configs = {
        repositories = {
          # You can give this a descriptive name.
          my-config-repo = {
            name           = "my-config-repo"
            type           = "git"
            url            = var.config_repo_url
            sshPrivateKey = replace(jsondecode(data.aws_secretsmanager_secret_version.config-repo-private-sshkey.secret_string)["config-repo-private-sshkey"], "\\n", "\n")
          }
        }
      }
    })
  ]
}
# <<< CHANGE END

# Wait for CRDs to be registered
resource "time_sleep" "wait_for_crd_registration" {
  create_duration = "30s"
  depends_on      = [helm_release.argocd]
}

# <<< REMOVED: The entire kubernetes_secret resource is no longer needed.
# The Helm chart now manages the creation of this secret internally.

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
        # Note: The repoURL must exactly match the URL provided in the helm values
        repoURL        = var.config_repo_url 
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

  # <<< CHANGE: Updated dependency. We no longer depend on the external secret.
  depends_on = [
    time_sleep.wait_for_crd_registration
  ]
}
