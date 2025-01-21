output "app_url" {
  value = module.telemetry_proxy.container_app_fqdn
}

output "application_insights_id" {
  value = azurerm_application_insights.this.id
}

output "log_analytics_workspace" {
  value = azurerm_log_analytics_workspace.this.id
}
