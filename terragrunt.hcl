generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "azurerm" {
    storage_account_name = "tfmod1espoolstatestorage"
    container_name       = "azure-verified-module-telemetry"
    key                  = "${path_relative_to_include()}.terraform.tfstate"
    snapshot             = true
  }
}
EOF
}