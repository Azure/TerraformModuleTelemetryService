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

module "endpoint_blob" {
  source                  = "./blob_for_url"
  endpoint                = "${module.container_apps.app_url["telemetry_proxy"]}/telemetry"
  resource_group_location = module.resource_group.resource_group_location
  resource_group_name     = module.resource_group.resource_group_name
}

data "azuread_group" "modtm_reader" {
  display_name = "Modtm Telemetry Reader"
}

resource "azurerm_role_assignment" "telemetry_reader" {
  for_each = tomap({
    application_insight = module.container_apps.application_insights_id
    log_analytics       = module.container_apps.log_analytics_workspace
  })
  role_definition_name = "Reader"
  scope                = sensitive(each.value)
  principal_id         = sensitive(data.azuread_group.modtm_reader.object_id)
}