# This Terraform configuration defines a Docker image and container for the Tdarr media transcoding application.
resource "docker_image" "tdarr" {
  provider     = docker.workstation
  name         = "ghcr.io/haveagitgat/tdarr:latest"
  keep_locally = true
}

resource "docker_container" "tdarr_server" {
  provider     = docker.workstation
  name         = "tdarr_server"
  image        = docker_image.tdarr.image_id
  restart      = "unless-stopped"
  network_mode = "host"

  # Crucial: Use the provider you passed from the root

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York",
    "serverIP=0.0.0.0", # Bind to all interfaces
    "serverPort=8266",
    "webUIPort=8265",
    "internalNode=true",
    "inContainer=true", # Disabled 
    "ffmpegVersion=7",
    "nodeName=ThinkmateServer",
    "openBrowser=true",
    "maxLogSizeMB=10",
    "auth=true",
    "authSecretKey=${var.tdarr_auth_key}",
    "seededApiKey=tapi_${var.tdarr_auth_key}"
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
  mounts {
    target = "/wd_media"
    source = "/mnt/wd_drive/data" # Your WD HDD library
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}


resource "docker_image" "tdarr_node" {
  provider     = docker.workstation
  name         = "ghcr.io/haveagitgat/tdarr_node:latest"
  keep_locally = true
}

resource "docker_container" "tdarr_node" {
  provider = docker.workstation
  name     = "tdarr-node"
  image    = docker_image.tdarr_node.image_id
  restart  = "unless-stopped"
  runtime  = "nvidia"

  # Changed to host mode
  network_mode = "host"

  device_requests {
    driver       = "nvidia"
    count        = -1
    capabilities = ["gpu", "compute", "utility", "video"]
  }

  env = [
    "TZ=America/New_York",
    "PUID=1000",
    "PGID=1000",
    "UMASK_SET=002",
    "nodeName=ThinkmateNode",
    "serverURL=http://100.106.96.18:8266",
    "serverPort=8266",
    "inContainer=true",
    "ffmpegVersion=7",
    "nodeType=mapped",
    "priority=-1",
    "maxLogSizeMB=10",
    "pollInterval=2000",
    "transcodegpuWorkers=1",
    "transcodecpuWorkers=1",
    "auth=true",
    "apiKey=tapi_${var.tdarr_auth_key}",
    "NVIDIA_VISIBLE_DEVICES=all",
    "NVIDIA_DRIVER_CAPABILITIES=all"
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

  mounts {
    target = "/wd_media"
    source = "/mnt/wd_drive/data"
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}