variable "acr_url" {
  type = string
}

variable "acr_user_name" {
  type = string
}

variable "acr_user_password" {
  type      = string
  sensitive = true
}

variable "application_insights_instrumentation_key" {
  type      = string
  sensitive = true
}

variable "docker_image" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "telemetry_proxy_diag" {
  type     = bool
  default  = false
  nullable = false
}
