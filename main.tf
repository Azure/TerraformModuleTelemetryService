locals {
  image_name = "telemetry_proxy"
}

resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "azure-verified-module-telemetry"
}

module "telemetry_proxy" {
  source                         = "Azure/container-apps/azure"
  version                        = "0.1.0"
  container_app_environment_name = "telemetry-proxy"
  container_app_environment_infrastructure_subnet_id = azurerm_subnet.container_apps.id
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
        registry = [
          {
            server               = azurerm_container_registry.this.login_server
            username             = azurerm_container_registry_token.pull.name
            password_secret_name = "secname"
          }
        ]
      }
    }
  }
  container_app_secrets = {
    telemetry_proxy = [
      {
        name = "secname"
        value = azurerm_container_registry_token_password.pull_password.password1[0].value
      }
    ]
  }
  location                     = azurerm_resource_group.this.location
  log_analytics_workspace_name = "telemetry-proxy-log-analytics-workspace"
  resource_group_name          = azurerm_resource_group.this.name
  depends_on                   = [terraform_data.docker_push]
}