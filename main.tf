module "resource_group" {
  source = "./resource_group"
}

module "acr" {
  source              = "./acr"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
}

module "docker_image" {
  source       = "./docker_image"
  password     = module.acr.push_password
  registry_url = module.acr.registry_url
  username     = module.acr.push_username
  image_tag    = var.image_tag
}

module "container_apps" {
  source              = "./container_apps"
  acr_url             = module.acr.registry_url
  acr_user_name       = module.acr.pull_username
  acr_user_password   = module.acr.pull_password
  docker_image        = module.docker_image.docker_image
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  subnet_id           = module.acr.container_apps_subnet_id
}

module "endpoint_blob" {
  source                  = "./blob_for_url"
  endpoint                = module.container_apps.app_url["telemetry_proxy"]
  resource_group_location = module.resource_group.resource_group_location
  resource_group_name     = module.resource_group.resource_group_name
}