terraform {
  required_version = ">= 1.14.6"
  required_providers {
    docker = {
      source                = "kreuzwerker/docker"
      version               = "3.6.2"
      configuration_aliases = [docker.optiplex]
    }
  }
}
