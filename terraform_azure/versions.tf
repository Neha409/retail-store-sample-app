terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  subscription_id = "80f05279-b635-4921-b71a-9d977e6f64ab"
  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
      
    }

  }
}

# Configure kubernetes & helm providers using the AKS credentials output
# by the azurerm_kubernetes_cluster resource. This avoids needing a
# separate `az aks get-credentials` step before running terraform apply
# for the addons.
#
# NOTE: because these provider blocks reference attributes of a resource
# that doesn't exist yet on a brand-new "terraform apply", Terraform can
# fail on the very first run with:
#   "Invalid provider configuration ... value depends on resource
#    attributes that cannot be determined until apply"
# If you hit that, apply in two steps instead of one:
#   terraform apply -target=azurerm_kubernetes_cluster.aks
#   terraform apply
# The first run creates only the cluster; the second run has real
# (known) kube_config values to configure these providers with, and
# installs the Helm addons. See README.md "Applying" section.
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}


