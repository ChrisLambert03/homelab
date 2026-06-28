terraform {
  required_version = ">= 1.14.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.0.0"
    }
    # nginxproxymanager = {
    #   source  = "Sander0542/nginxproxymanager"
    #   version = "1.2.2"
    # }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = " 5.9.0"
    }
  }
}
