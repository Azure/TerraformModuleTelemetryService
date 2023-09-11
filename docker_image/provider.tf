terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}