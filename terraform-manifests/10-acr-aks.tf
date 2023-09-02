resource "azurerm_container_registry" "acr_aks_rg" {
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}