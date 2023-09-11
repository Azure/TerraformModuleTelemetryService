resource "azurerm_traffic_manager_profile" "this" {
  name                   = "tfmodtelemetry-svc"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "telemetry"
    ttl           = 600
  }
  monitor_config {
    port                        = 443
    protocol                    = "HTTPS"
    expected_status_code_ranges = ["200-202"]
    interval_in_seconds         = 30
    path                        = "/telemetry"
    timeout_in_seconds          = 10
  }
}

resource "azurerm_traffic_manager_external_endpoint" "this" {
  name              = "endpoint"
  profile_id        = azurerm_traffic_manager_profile.this.id
  target            = var.telemetry_svc_fqdn
  endpoint_location = var.resource_group_location
  weight            = 100
}