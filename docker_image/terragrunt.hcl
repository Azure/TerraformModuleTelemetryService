include "root" {
  path = find_in_parent_folders()
}

dependency "acr" {
  config_path  = "../acr"
  mock_outputs = {
    push_password = "push_password"
    pull_password = "pull_password"
    push_username = "push_user"
    pull_username = "pull_user"
    registry_url  = "dummy.aczurecr.io"
  }
}

inputs = {
  password            = dependency.acr.outputs.push_password
  registry_url = dependency.acr.outputs.registry_url
  username = dependency.acr.outputs.push_username

}