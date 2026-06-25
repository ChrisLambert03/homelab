# 1. Pull the Prowlarr Image
/*
data "docker_registry_image" "prowlarr" {
  name = "lscr.io/linuxserver/prowlarr:latest"
}

resource "docker_image" "prowlarr" {
  provider      = docker.workstation
  name          = data.docker_registry_image.prowlarr.name
  pull_triggers = [data.docker_registry_image.prowlarr.sha256_digest]
  keep_locally  = false
}

# 2. Prowlarr Container
resource "docker_container" "prowlarr" {
  provider     = docker.workstation
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

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
*/