variable "password" {
  type      = string
  sensitive = true
}

variable "registry_url" {
  type = string
}

variable "username" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}
