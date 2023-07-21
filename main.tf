#module "container-apps" {
#  source  = "Azure/container-apps/azure"
#  version = "0.1.0"
#  # insert the 5 required variables here
#  container_app_environment_name = "telemetry_proxy"
#  container_apps                 = {}
#  location                       = azurerm_resource_group.this.location
#  log_analytics_workspace_name   = azurerm_log_analytics_workspace.this.name
#  resource_group_name            = azurerm_resource_group.this.name
#}

locals {
  image_name = "telemetry_proxy"
}

resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "azure-verified-module-telemetry"
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = "telemetry-proxy-log-analytics-workspace"
  resource_group_name = azurerm_resource_group.this.name
}

module "telemetry_proxy" {
  source                         = "Azure/container-apps/azure"
  version                        = "0.1.0"
  container_app_environment_name = "telemetry-proxy"
  container_apps                 = {
    telemetry_proxy = {
      name          = "telemetry-proxy"
      revision_mode = "Single"
      template = {
        containers = [
          {
            name   = "telemetry-proxy"
            memory = "0.5Gi"
            cpu    = "0.25"
            image  = "${docker_image.proxy.name}:${var.image_tag}"
          }
        ]
        ingress = {
          allow_insecure_connection = true
          external_enabled          = true
          target_port               = 9001
          traffic_weight            = {
            latest_revision = true
            percentage      = 100
          }
        }
      }
    }
  }
  location                     = azurerm_resource_group.this.location
  log_analytics_workspace_name = azurerm_log_analytics_workspace.this.name
  resource_group_name          = azurerm_resource_group.this.name
  depends_on                   = [terraform_data.docker_push]
}