# --- Images ---
data "docker_registry_image" "radarr" {
  name = "lscr.io/linuxserver/radarr:latest"
}

resource "docker_image" "radarr" {
  provider      = docker.workstation
  name          = data.docker_registry_image.radarr.name
  pull_triggers = [data.docker_registry_image.radarr.sha256_digest]
  keep_locally  = false
}

# --- Radarr Container ---
resource "docker_container" "radarr" {
  provider     = docker.workstation
  name         = "radarr"
  image        = docker_image.radarr.image_id
  restart      = "unless-stopped"
  network_mode = "host"

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York"
  ]

  mounts {
    target = "/config"
    source = "/home/chris/services/radarr/config"
    type   = "bind"
  }

  mounts {
    target = "/data"
    source = "/mnt/blue_drive/data"
    type   = "bind"
  }

  mounts {
    target = "/more_data"
    source = "/mnt/black_drive/data"
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}

