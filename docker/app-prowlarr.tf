# 1. Pull the Prowlarr Image
resource "docker_image" "prowlarr" {
  name         = "lscr.io/linuxserver/prowlarr:latest"
  keep_locally = false
}

# 2. Prowlarr Container
resource "docker_container" "prowlarr" {
  name         = "prowlarr"
  image        = docker_image.prowlarr.image_id
  restart      = "unless-stopped"
  network_mode = "host"

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York"
  ]

  mounts {
    target = "/config"
    source = "/home/chris/services/prowlarr/config"
    type   = "bind"
  }
}