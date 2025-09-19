# Corrected argocd/main.tf

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
    # We now require the time provider
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

data "aws_secretsmanager_secret_version" "mywebsite-token" {
  # This uses the secret name you pass into the module.
  secret_id = var.config_repo_secret_name
}

resource "kubernetes_secret" "config_repo_ssh" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = var.config_repo_secret_name
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name          = var.config_repo_secret_name
    type          = "git"
    url           = var.config_repo_url
    sshPrivateKey = data.aws_secretsmanager_secret_version.mywebsite-token.secret_string
  }
}


resource "time_sleep" "wait_for_crd_registration" {
  create_duration = "30s"

  depends_on = [
    helm_release.argocd
  ]
}

# This creates the main "App of Apps" in ArgoCD.

resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "root-app"
      "namespace" = "argocd"
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/liormilliger/mywebsite-k8s.git"
        "path"           = "argocd-apps"
        "targetRevision" = "main"
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "argocd"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }

  # This now depends on the time_sleep resource, ensuring the delay has passed.
  depends_on = [
    resource.time_sleep.wait_for_crd_registration
  ]
}


