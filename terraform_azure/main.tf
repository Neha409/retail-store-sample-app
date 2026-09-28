resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  resource_group_name = coalesce(var.resource_group_name, "${var.prefix}-rg")
  cluster_name         = "${var.prefix}-aks-${random_string.suffix.result}"
  dns_prefix           = "${var.prefix}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.prefix}-law-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = local.dns_prefix
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name                = "system"
    vm_size             = var.vm_size
    node_count          = var.node_count
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
    os_disk_size_gb     = 64
    type                = "VirtualMachineScaleSets"
    zones               = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = "standard"
    service_cidr      = "10.240.0.0/16"
    dns_service_ip    = "10.240.0.10"
    network_policy    = var.network_plugin == "azure" ? "azure" : null
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  azure_policy_enabled = true
  depends_on = [azurerm_subnet_network_security_group_association.aks]

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count, # allow autoscaler to manage node count
    ]
  }
}
