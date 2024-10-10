resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "avm-telemetry"

  tags = {
    do_not_delete = ""
    env           = "prod"
  }
}