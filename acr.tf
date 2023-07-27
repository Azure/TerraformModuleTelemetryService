module "public_ip" {
  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
}

resource "azurerm_container_registry" "this" {
  location            = azurerm_resource_group.this.location
  name                = "avmtelemetry"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Premium"
  public_network_access_enabled = true
  network_rule_set  {
    default_action = "Deny"

    ip_rule {
      action = "Allow"
      ip_range = "${module.public_ip.public_ip}/32"
    }
  }
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

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "telemetry"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "acr" {
  address_prefixes     = [cidrsubnet("192.168.0.0/24", 4, 0)]
  name                 = "acr"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies_enabled = false
  private_link_service_network_policies_enabled = false
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "container_apps" {
  address_prefixes     = ["192.168.1.0/24"]
  name                 = "containerapps"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_private_endpoint" "pep" {
  location            = azurerm_resource_group.this.location
  name                = "mype"
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.acr.id

  private_service_connection {
    is_manual_connection           = false
    name                           = "countainerregistryprivatelink"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
  }
}

resource "azurerm_private_dns_zone" "pdz" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink_private" {
  name                  = "mydnslink"
  private_dns_zone_name = azurerm_private_dns_zone.pdz.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}