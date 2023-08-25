terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.56, < 4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}