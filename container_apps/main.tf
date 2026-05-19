locals {
  image_name               = "telemetry_proxy"
  port                     = 8080
  telemetry_proxy_app_name = "telemetry-proxy"
}

data "azurerm_subscription" "current" {}

data "azurerm_role_definition" "owner" {
  name  = "Owner"
  scope = data.azurerm_subscription.current.id
}

data "azurerm_container_app" "telemetry_proxy" {
  name                = local.telemetry_proxy_app_name
  resource_group_name = var.resource_group_name

  depends_on = [module.telemetry_proxy]
}

locals {
  owner_role_definition_id = split("/", data.azurerm_role_definition.owner.role_definition_id)[length(split("/", data.azurerm_role_definition.owner.role_definition_id)) - 1]
  telemetry_proxy_endpoint = "${module.telemetry_proxy.container_app_fqdn["telemetry_proxy"]}/telemetry"
  telemetry_proxy_arm_id   = data.azurerm_container_app.telemetry_proxy.id
}

resource "azurerm_application_insights" "this" {
  application_type    = "other"
  location            = var.location
  name                = "ai-avm-telemetry"
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-avm-telemetry"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 730
}

resource "azurerm_application_insights_standard_web_test" "telemetry_proxy_heartbeat" {
  name                    = "telemetry-proxy-heartbeat"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.this.id
  geo_locations           = ["us-va-ash-azr", "us-ca-sjc-azr"]
  frequency               = 300
  timeout                 = 30
  enabled                 = true
  retry_enabled           = true

  request {
    url                              = local.telemetry_proxy_endpoint
    http_verb                        = "GET"
    follow_redirects_enabled         = true
    parse_dependent_requests_enabled = false
  }

  validation_rules {
    expected_status_code        = 200
    ssl_check_enabled           = true
    ssl_cert_remaining_lifetime = 7
  }
}

resource "azurerm_monitor_action_group" "telemetry_proxy" {
  name                = "ag-telemetry-proxy"
  resource_group_name = var.resource_group_name
  short_name          = "telproxy"

  arm_role_receiver {
    name                    = "subscription-owners"
    role_id                 = local.owner_role_definition_id
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "telemetry_proxy_heartbeat" {
  name                = "telemetry-proxy-heartbeat-failed"
  resource_group_name = var.resource_group_name
  scopes = [
    azurerm_application_insights.this.id,
    azurerm_application_insights_standard_web_test.telemetry_proxy_heartbeat.id,
  ]

  description              = <<-EOT
    The avm telemetry service heartbeat check failed from one or more test locations.
    Telemetry endpoint: ${local.telemetry_proxy_endpoint}
    Container App ARM ID: ${local.telemetry_proxy_arm_id}
  EOT
  frequency                = "PT5M"
  window_size              = "PT5M"
  target_resource_type     = "Microsoft.Insights/webtests"
  target_resource_location = var.location

  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_standard_web_test.telemetry_proxy_heartbeat.id
    component_id          = azurerm_application_insights.this.id
    failed_location_count = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.telemetry_proxy.id
  }
}

module "telemetry_proxy" {
  source                                             = "Azure/container-apps/azure"
  version                                            = "0.2.0"
  container_app_environment_name                     = "telemetry-proxy"
  container_app_environment_infrastructure_subnet_id = var.subnet_id
  container_apps = {
    telemetry_proxy = {
      name          = local.telemetry_proxy_app_name
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
              ], (var.telemetry_proxy_diag ? [{
                name  = "DIAG"
                value = "1"
                }] : []), [for i, r in [
                "registry.terraform.io/[A|a]zure/.+",
                "registry.opentofu.org/[A|a]zure/.+",
                "git::https://github\\.com/[A|a]zure/.+",
                "git::ssh:://git@github\\.com/[A|a]zure/.+",
                ] : {
                name  = "SOURCE_REGEX_${i}"
                value = r
            }]))
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
