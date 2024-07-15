locals {
  image_name = "telemetry_proxy"
}

locals {
  port = 8080
}

resource "azurerm_application_insights" "this" {
  application_type    = "other"
  location            = var.location
  name                = "avm-telemetry"
  resource_group_name = var.resource_group_name
  retention_in_days   = 730
}

module "telemetry_proxy" {
  source                                             = "Azure/container-apps/azure"
  version                                            = "0.2.0"
  container_app_environment_name                     = "telemetry-proxy"
  container_app_environment_infrastructure_subnet_id = var.subnet_id
  container_apps = {
    telemetry_proxy = {
      name          = "telemetry-proxy"
      revision_mode = "Single"
      registry = [
        {
          server               = var.acr_url
          username             = var.acr_user_name
          password_secret_name = "secname"
        }
      ]
      template = {
        containers = [
          {
            name   = "telemetry-proxy"
            memory = "0.5Gi"
            cpu    = 0.25
            image  = var.docker_image
            env = toset(concat([
              {
                name        = "INSTRUMENTATION_KEY"
                secret_name = "ikey"
              },
              {
                name  = "PORT"
                value = local.port
              },
              ], var.telemetry_proxy_diag ? [{
                name  = "DIAG"
                value = "1"
            }] : []))
          }
        ]
      }
      ingress = {
        allow_insecure_connection = false
        external_enabled          = true
        target_port               = local.port
        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
      }
    }
  }
  container_app_secrets = {
    telemetry_proxy = [
      {
        name  = "secname"
        value = var.acr_user_password
      },
      {
        name  = "ikey"
        value = azurerm_application_insights.this.instrumentation_key
      }
    ]
  }
  location                     = var.location
  log_analytics_workspace_name = "telemetry-proxy-log-analytics-workspace"
  resource_group_name          = var.resource_group_name
}