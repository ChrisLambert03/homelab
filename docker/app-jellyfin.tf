# Pull Jellyfin Image
resource "docker_image" "jellyfin" {
  name         = "jellyfin/jellyfin:latest"
  keep_locally = false # allow Terraform to remove the image when the container is destroyed
}

# Jellyfin docker container definition
resource "docker_container" "jellyfin" {
  name  = "jellyfin"
  image = docker_image.jellyfin.image_id
  restart = "unless-stopped"
  network_mode = "host"

  
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York",
    "JELLYFIN_PublishedServerUrl=http://${var.workstation_ip}:8096"
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
  mounts{
   target = "/data/black_drive"
   source = var.black_drive_path
   type   = "bind"
  }
}