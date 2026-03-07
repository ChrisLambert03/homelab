# Pull Jellyfin Image
resource "docker_image" "jellyfin" {
  name         = "jellyfin/jellyfin:latest"
  keep_locally = false # allow Terraform to remove the image when the container is destroyed
}
# 1. The Macvlan Network (Keep this as is)
resource "docker_network" "jellyfin_macvlan" {
  name   = "jellyfin_macvlan"
  driver = "macvlan"
  options = { parent = "enp5s0" }
  ipam_config {
    subnet  = "10.0.0.0/24"
    gateway = "10.0.0.1"
  }
}

# 2. The Jellyfin Container
resource "docker_container" "jellyfin" {
  name    = "jellyfin"
  image   = docker_image.jellyfin.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name         = docker_network.jellyfin_macvlan.name
    ipv4_address = "10.0.0.250"  # outside of dhcp range to avoid conflicts
  }

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York",
    # FIX: Point the URL to the container's own IP
    "JELLYFIN_PublishedServerUrl=http://10.0.0.250:8096"
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
