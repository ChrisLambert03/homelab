# --- Sonarr Image ---
resource "docker_image" "sonarr" {
  name = "lscr.io/linuxserver/sonarr:latest"
}
# --- Sonarr Container ---
resource "docker_container" "sonarr" {
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
}