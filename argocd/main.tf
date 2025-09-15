# 1. Create the namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# 2. Install ArgoCD using the Helm chart
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.51.2" # Use a specific version for stability

  values = [
    # Add any custom ArgoCD values here if needed
    yamlencode({
      server = {
        # Ingress configuration can be added here later
      }
    })
  ]
}

# 3. Create a namespace for your website application
resource "kubernetes_namespace" "my_app" {
  metadata {
    name = "my-website"
  }
}

# 4. The "App of Apps": This ArgoCD Application tells ArgoCD to monitor a Git repo
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
        # <-- MODIFY THIS to your Kubernetes repo URL
        "repoURL"        = "https://github.com/liormilliger/mywebsite-k8s.git" 
        
        # <-- MODIFY THIS to the path inside that repo
        "path"           = "argocd"
        "targetRevision" = "main" # Or your repo's default branch
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

  depends_on = [
    helm_release.argocd
  ]
}