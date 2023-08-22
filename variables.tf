variable "image_tag" {
  type    = string
  default = "latest"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "telemetry_proxy_diag" {
  type     = bool
  default  = false
  nullable = false
}
