resource "azurerm_container_registry" "this" {
  location            = azurerm_resource_group.this.location
  name                = "avmtelemetry"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Basic"
}

data "azurerm_container_registry_scope_map" "pull" {
  container_registry_name = azurerm_container_registry.this.name
  name                    = "_repositories_pull"
  resource_group_name     = azurerm_container_registry.this.resource_group_name
}

data "azurerm_container_registry_scope_map" "push" {
  container_registry_name = azurerm_container_registry.this.name
  name                    = "_repositories_push"
  resource_group_name     = azurerm_container_registry.this.resource_group_name
}

resource "azurerm_container_registry_token" pull {
  container_registry_name = azurerm_container_registry.this.name
  name                    = "pull-token"
  resource_group_name     = azurerm_container_registry.this.resource_group_name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull.id
}

resource "azurerm_container_registry_token_password" "pull_password" {
  container_registry_token_id = azurerm_container_registry_token.pull.id
  password1 {}
}

resource "azurerm_container_registry_token" "push" {
  container_registry_name = azurerm_container_registry.this.name
  name                    = "push-token"
  resource_group_name     = azurerm_container_registry.this.resource_group_name
  scope_map_id            = data.azurerm_container_registry_scope_map.push.id
}

resource "azurerm_container_registry_token_password" "push_password" {
  container_registry_token_id = azurerm_container_registry_token.push.id
  password1 {}
}