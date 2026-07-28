# Pull Jellyfin Image
data "docker_registry_image" "jellyfin" {
  name = "lscr.io/linuxserver/jellyfin:latest"
}

resource "docker_image" "jellyfin" {
  provider      = docker.workstation
  name          = data.docker_registry_image.jellyfin.name
  pull_triggers = [data.docker_registry_image.jellyfin.sha256_digest]
  keep_locally  = false # allow Terraform to remove the image when the container is destroyed
}
# 1. The Macvlan Network (Keep this as is)
resource "docker_network" "jellyfin_macvlan" {
  provider = docker.workstation
  name     = "jellyfin_macvlan"
  driver   = "macvlan"
  options  = { parent = "enp5s0" }
  ipam_config {
    subnet  = "10.0.0.0/24"
    gateway = "10.0.0.1"
  }
}

# 2. The Jellyfin Container
resource "docker_container" "jellyfin" {
  provider = docker.workstation
  name     = "jellyfin"
  image    = docker_image.jellyfin.image_id
  restart  = "unless-stopped"
  runtime  = "nvidia"

  networks_advanced {
    name         = docker_network.jellyfin_macvlan.name
    ipv4_address = var.jellyfin_macvlan_ip
  }

  # NVIDIA GPU support
  device_requests {
    driver       = "nvidia"
    count        = -1 # -1 means all GPUs
    capabilities = ["gpu", "compute", "utility", "video"]
  }

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York",
    # FIX: Point the URL to the container's own IP
    "JELLYFIN_PublishedServerUrl=http://${var.jellyfin_macvlan_ip}:8096",
    "NVIDIA_VISIBLE_DEVICES=all",
    "NVIDIA_DRIVER_CAPABILITIES=all",
  ]

  # Config folder for metadata/database

  mounts {

    target = "/config"
    source = var.jellyfin_config_path
    type   = "bind"
  }

  mounts {
    target = "/cache"
    source = var.jellyfin_cache_path
    type   = "bind"
  }

  # All media mapped to /data

  mounts {
    target = "/data/blue_drive"
    source = var.blue_drive_path
    type   = "bind"
  }

  mounts {
    target = "/data/black_drive"
    source = var.black_drive_path
    type   = "bind"
  }

  mounts {
    target = "/data/wd_drive"
    source = var.wd_drive_path
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}

