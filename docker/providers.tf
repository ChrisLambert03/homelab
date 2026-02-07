terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    nginxproxymanager = {
      source  = "Sander0542/nginxproxymanager"
      version = "1.2.2"
    }
  }
}
