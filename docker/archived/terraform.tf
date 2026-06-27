terraform {
  required_version = ">= 1.14.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.0.0"
    }
  }
}
