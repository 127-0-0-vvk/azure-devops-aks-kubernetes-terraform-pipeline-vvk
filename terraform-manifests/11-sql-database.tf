
resource "azurerm_storage_account" "akssql" {
  name                     = "akssql"
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Basic"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "akssqls" {
  name                         = "akssqls"
  resource_group_name          = azurerm_resource_group.aks_rg.name
  location                     = azurerm_resource_group.aks_rg.location
  version                      = "12.0"
  administrator_login          = "admin"
  administrator_login_password = "Password"

}