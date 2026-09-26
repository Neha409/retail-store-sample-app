############################
# Namespaces
############################

resource "kubernetes_namespace" "ingress_nginx" {
  count = var.enable_nginx_ingress ? 1 : 0
  metadata {
    name = "ingress-nginx"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  metadata {
    name = "cert-manager"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "argocd" {
  count = var.enable_argocd ? 1 : 0
  metadata {
    name = "argocd"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

############################
# NGINX Ingress Controller
############################

resource "helm_release" "nginx_ingress" {
  count = var.enable_nginx_ingress ? 1 : 0

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_chart_version
  namespace  = kubernetes_namespace.ingress_nginx[0].metadata[0].name

  create_namespace = false
  atomic           = true
  timeout          = 600

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }
}

############################
# cert-manager
############################

resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version
  namespace  = kubernetes_namespace.cert_manager[0].metadata[0].name

  create_namespace = false
  atomic           = true
  timeout          = 600

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

# ClusterIssuer for Let's Encrypt (production). Requires the cert-manager
# CRDs to already be installed, hence the explicit depends_on.
resource "kubernetes_manifest" "letsencrypt_prod_issuer" {
  count = var.enable_cert_manager ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

############################
# Argo CD
############################

resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd[0].metadata[0].name

  create_namespace = false
  atomic           = true
  timeout          = 600

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Expose Argo CD UI via the nginx ingress controller.
  # Update the host below to a real DNS name that points at the
  # ingress-nginx LoadBalancer IP before enabling TLS in production.
  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "server.ingress.hostname"
    value = "argocd.example.com"
  }

  set {
    name  = "server.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-prod"
  }

  set {
    name  = "server.ingress.tls"
    value = "true"
  }

  # Run the server in insecure mode behind the ingress controller, which
  # terminates TLS. Remove this if you prefer TLS passthrough instead.
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  depends_on = [
    helm_release.nginx_ingress,
    helm_release.cert_manager,
  ]
}
