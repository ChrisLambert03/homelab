# --- Images ---
resource "docker_image" "radarr" {
  name = "lscr.io/linuxserver/radarr:latest"
}

# --- Radarr Container ---
resource "docker_container" "radarr" {
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
}

