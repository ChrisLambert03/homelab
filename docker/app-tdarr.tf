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
    "internalNode=true",
    "inContainer=true", # Disabled 
    "ffmpegVersion=7",
    "nodeName=ThinkmateServer",
    "openBrowser=true",
    "maxLogSizeMB=10"
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


resource "docker_image" "tdarr_node" {
  name = "ghcr.io/haveagitgat/tdarr_node:latest"
}

resource "docker_container" "tdarr_node" {
  name         = "tdarr-node"
  image        = docker_image.tdarr_node.image_id
  restart      = "unless-stopped"
  
  # Changed to host mode
  network_mode = "host"

  env = [
    "TZ=America/New_York",
    "PUID=1000",
    "PGID=1000",
    "UMASK_SET=002",
    "nodeName=ThinkmateNode",
    "serverIP=100.106.96.18", # Since it's on the same host, 0.0.0.0 or localhost works
    "serverPort=8266",
    "inContainer=true",
    "ffmpegVersion=7",
    "nodeType=mapped",
    "priority=-1",
    "maxLogSizeMB=10",
    "pollInterval=2000",
    "transcodegpuWorkers=0",
    "transcodecpuWorkers=2"
  ]

  # Mounts - Keeping your paths consistent
  mounts {
    target = "/app/configs"
    source = "/home/chris/services/tdarr/node/configs"
    type   = "bind"
  }

  mounts {
    target = "/app/logs"
    source = "/home/chris/services/tdarr/node/logs"
    type   = "bind"
  }

  mounts {
    target = "/temp"
    source = "/mnt/transcode_cache"
    type   = "bind"
  }

  mounts {
    target = "/media"
    source = "/mnt/black_drive/data"
    type   = "bind"
  }
  mounts {
        target = "/more_media"
        source = "/mnt/blue_drive/data"
        type   = "bind"
  }
}