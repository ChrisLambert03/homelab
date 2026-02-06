# Configure the Docker provider to connect to a remote Docker host via SSH
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

provider "docker" {
  host     = "ssh://${var.ssh_user}@${var.workstation_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# Configuration-based authentication
provider "nginxproxymanager" {
  url  = "http://${var.workstation_ip}:81"
  username = var.npm_user
  password = var.npm_password
}