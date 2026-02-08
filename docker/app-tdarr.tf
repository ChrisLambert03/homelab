# This Terraform configuration defines a Docker image and container for the Tdarr media transcoding application.
resource "docker_image" "tdarr" {
  name = "ghcr.io/haveagitgat/tdarr:latest"
}

resource "docker_container" "tdarr_server" {
  name         = "tdarr_server"
  image        = docker_image.tdarr.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  
  # Crucial: Use the provider you passed from the root

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York",
    "serverIP=100.106.96.18", #Thinkmate Node IP
    "serverPort=8266",
    "webUIPort=8265",
    "internalNode=false" # Disabled 
  ]

  mounts {
    target = "/app/configs"
    source = "/home/chris/services/tdarr/configs"
    type   = "bind"
  }

  mounts {
    target = "/app/server"
    source = "/home/chris/services/tdarr/data"
    type   = "bind"
  }

  mounts {
    target = "/temp"
    source = "/mnt/transcode_cache" # Your NVMe "Buffer"
    type   = "bind"
  }

  mounts {
    target = "/media"
    source = "/mnt/black_drive/data" # Your HDD library
    type   = "bind"
  }
  mounts {
    target = "/more_media"
    source = "/mnt/blue_drive/data" # Your second HDD library
    type   = "bind"
  }
}