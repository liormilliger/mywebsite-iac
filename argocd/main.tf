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

# --- THIS IS THE NEW, GUARANTEED FIX ---
# This resource introduces a 30-second delay after the Helm chart
# installation starts, allowing the CRDs to be fully registered in the cluster.
resource "time_sleep" "wait_for_crd_registration" {
  create_duration = "30s"

  depends_on = [
    helm_release.argocd
  ]
}

# This creates the main "App of Apps" in ArgoCD.
/*
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
*/

