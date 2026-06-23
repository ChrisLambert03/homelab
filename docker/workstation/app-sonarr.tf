# --- Sonarr Image ---
data "docker_registry_image" "sonarr" {
  name = "lscr.io/linuxserver/sonarr:latest"
}

resource "docker_image" "sonarr" {
  provider      = docker.workstation
  name          = data.docker_registry_image.sonarr.name
  pull_triggers = [data.docker_registry_image.sonarr.sha256_digest]
  keep_locally  = false
}
# --- Sonarr Container ---
resource "docker_container" "sonarr" {
  provider     = docker.workstation
  name         = "sonarr"
  image        = docker_image.sonarr.image_id
  restart      = "unless-stopped"
  network_mode = "host"

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York"
  ]

  mounts {
    target = "/config"
    source = "/home/chris/services/sonarr/config"
    type   = "bind"
  }

  mounts {
    target = "/data"
    source = "/mnt/blue_drive/data" # Updated to blue_drive
    type   = "bind"
  }

  mounts {
    target = "/more_data"
    source = "/mnt/black_drive/data"
    type   = "bind"
  }

  # Unified NAS Media Storage
  mounts {
    target = "/media"
    source = docker_volume.nas_media.name
    type   = "volume"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}