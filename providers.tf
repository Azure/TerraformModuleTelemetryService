terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.56, < 4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "docker" {
  registry_auth {
    address  = module.acr.registry_url
    username = module.acr.push_username
    password = module.acr.push_password
  }
}