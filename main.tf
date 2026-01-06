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
  registry_url = module.acr.registry_url
  image_tag    = var.image_tag
  depends_on   = [module.acr]
}

module "container_apps" {
  source               = "./container_apps"
  acr_url              = module.acr.registry_url
  acr_user_name        = module.acr.pull_username
  acr_user_password    = module.acr.pull_password
  docker_image         = module.docker_image.docker_image
  location             = module.resource_group.resource_group_location
  resource_group_name  = module.resource_group.resource_group_name
  subnet_id            = module.acr.container_apps_subnet_id
  telemetry_proxy_diag = true
}