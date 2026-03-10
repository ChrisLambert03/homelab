# Configure the Docker provider to connect to a remote Docker host via SSH
terraform {
  required_version = ">= 1.14.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    nginxproxymanager = {
      source  = "Sander0542/nginxproxymanager"
      version = "1.2.2"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.4"
    }
  }
}

provider "docker" {
  host     = "ssh://${var.ssh_user}@${var.workstation_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# Configuration-based authentication
provider "nginxproxymanager" {
  url      = "http://${var.workstation_ip}:81"
  username = var.npm_user
  password = var.npm_password
}
# The libvirt provider is configured to connect to a remote host via SSH.
provider "libvirt" {
  uri = "qemu+ssh://${var.ssh_user}@${var.workstation_ip}/system"
}