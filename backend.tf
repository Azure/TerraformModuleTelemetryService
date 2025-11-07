terraform {
  backend "azurerm" {
    storage_account_name = "avmtelemetrystate"
    resource_group_name  = "avm-telemetry-state"
    container_name       = "azure-verified-tfmod-runner-state"
    key                  = "telemetry/terraform.tfstate"
    snapshot             = true
    use_msi              = true
  }
}