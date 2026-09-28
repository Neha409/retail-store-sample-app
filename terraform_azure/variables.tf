variable "prefix" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "aksdemo"
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group (leave null to auto-generate from prefix)"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster (leave null for latest supported by AKS)"
  type        = string
  default     = null
}

variable "node_count" {
  description = "Initial number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum node count for cluster autoscaler"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum node count for cluster autoscaler"
  type        = number
  default     = 2
}

variable "vnet_address_space" {
  description = "Address space for the VNet (must not overlap the AKS service CIDR 10.240.0.0/16)"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS node subnet"
  type        = string
  default     = "10.10.0.0/20"
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "network_plugin" {
  description = "Network plugin to use (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# --- Add-on toggles ---

variable "enable_nginx_ingress" {
  description = "Whether to install the ingress-nginx Helm chart"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Whether to install the cert-manager Helm chart"
  type        = bool
  default     = true
}

variable "enable_argocd" {
  description = "Whether to install the Argo CD Helm chart"
  type        = bool
  default     = true
}

variable "acme_email" {
  description = "Email address used for the Let's Encrypt ClusterIssuer created by cert-manager"
  type        = string
  default     = "admin@example.com"
}

# --- Helm chart versions (pin these for repeatable builds) ---

variable "nginx_chart_version" {
  type    = string
  default = "4.11.2" # ingress-nginx
}

variable "cert_manager_chart_version" {
  type    = string
  default = "v1.15.3"
}

variable "argocd_chart_version" {
  type    = string
  default = "7.6.12"
}
