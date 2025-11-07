
# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = var.node_pool_name
    node_count     = 1
    vm_size        = var.vm_size
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "basic"
    outbound_type      = "loadBalancer"
  }

  tags = {
    environment = "production"
    owner       = "Lewis"
  }
}


resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = false
}


# creates the data block to get the AKS cluster details
data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = azurerm_kubernetes_cluster.aks_cluster.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
}


# Assign the AcrPull role to the AKS cluster's managed identity
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id

  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
    azurerm_container_registry.acr
  ]
}






