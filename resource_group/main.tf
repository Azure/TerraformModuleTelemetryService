resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "avm-telemetry"

  tags = {
    env = "prod"
  }
}