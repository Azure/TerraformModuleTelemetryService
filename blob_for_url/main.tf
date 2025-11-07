resource "azurerm_storage_account" "endpoint" {
  account_replication_type      = "GRS"
  account_tier                  = "Standard"
  location                      = var.resource_group_location
  name                          = "avmtftelemetrysvc2"
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = true

  network_rules {
    default_action = "Allow"
  }
}

resource "azurerm_storage_container" "endpoint" {
  name                  = "blob"
  storage_account_name  = azurerm_storage_account.endpoint.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "endpoint" {
  name                   = "endpoint"
  storage_account_name   = azurerm_storage_account.endpoint.name
  storage_container_name = azurerm_storage_container.endpoint.name
  type                   = "Block"
  content_type           = "text/plain"
  source_content         = var.endpoint
}