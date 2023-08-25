include "root" {
  path = find_in_parent_folders()
}

dependency "resource_group" {
  config_path  = "../resource_group"
  mock_outputs = {
    resource_group_location = "eastus"
    resource_group_name     = "avm-telemetry"
  }
}

dependency "acr" {
  config_path  = "../acr"
  mock_outputs = {
    push_password            = "push_password"
    pull_password            = "pull_password"
    push_username            = "push_user"
    pull_username            = "pull_user"
    registry_url             = "dummy.azurecr.io"
    container_apps_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/virtualNetworks/myvnet1/subnets/mysubnet1"
  }
}

dependency "docker_image" {
  config_path  = "../docker_image"
  mock_outputs = {
    docker_image = "dummy.azurecr.io/telemetry_proxy:latest"
  }
}

inputs = {
  acr_user_name       = dependency.acr.outputs.pull_username
  acr_user_password   = dependency.acr.outputs.pull_password
  acr_url             = dependency.acr.outputs.registry_url
  docker_image        = dependency.docker_image.outputs.docker_image
  location            = dependency.resource_group.outputs.resource_group_location
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  subnet_id           = dependency.acr.outputs.container_apps_subnet_id
}