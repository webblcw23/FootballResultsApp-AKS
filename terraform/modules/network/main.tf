
# Virtual Network
resource "azurerm_virtual_network" "rangers_vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
    location            = var.location
    resource_group_name = var.resource_group_name
}

# Subnet 
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.rangers_vnet.name
   address_prefixes     = var.subnet_prefixes
}


# NSG creation
resource "azurerm_network_security_group" "rangers_nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

security_rule {
  name                       = "AllowHTTP"
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

}

# NSG Association with Subnet
resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.rangers_nsg.id
}


resource "azurerm_role_assignment" "aks_subnet_join" {
  scope                = azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id = var.aks_principal_id
  
}


