terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0"
    }
  }
}

provider "docker" {
  registry_auth {
    address  = var.registry_url
    username = var.username
    password = var.password
  }
}