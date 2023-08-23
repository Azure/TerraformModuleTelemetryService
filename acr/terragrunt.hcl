dependency "resource_group" {
  config_path = "../resource_group"
  mock_outputs = {
    resource_group_location = "eastus"
    resource_group_name = "avm-telemetry"
  }
}

inputs = {
  location = dependency.resource_group.outputs.resource_group_location
  resource_group_name = dependency.resource_group.outputs.resource_group_name
}