output "push_password" {
  value = azurerm_container_registry_token_password.push_password.password1[0].value
  sensitive = true
}

output "push_username" {
  value = azurerm_container_registry_token.push.name
}

output "pull_username" {
  value = azurerm_container_registry_token.pull.name
}

output "pull_password" {
  value = azurerm_container_registry_token_password.pull_password.password1[0].value
  sensitive = true
}

output "registry_url" {
  value = azurerm_container_registry.this.login_server
}

output "container_apps_subnet_id" {
  value = azurerm_subnet.container_apps.id
}