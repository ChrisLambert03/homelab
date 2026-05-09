# Retroarch Image
resource "docker_image" "retroarch" {
  provider     = docker.workstation
  name         = "lscr.io/linuxserver/retroarch:latest"
  keep_locally = true
}

# 3. CONTAINER
resource "docker_container" "retroarch" {
  provider      = docker.workstation
  name          = "retroarch"
  image         = docker_image.retroarch.image_id
  restart       = "unless-stopped"
  runtime       = "nvidia"
  privileged    = true
  security_opts = ["seccomp=unconfined"]

  # SHARED MEMORY: 2GB for smooth Wayland frames
  shm_size = 2048

  # PORT MAPPING: Moved to 3005 to avoid your local conflict
  ports {
    internal = 3000
    external = 3005
  }

  # NVIDIA GPU PASSTHROUGH
  device_requests {
    driver       = "nvidia"
    count        = -1
    capabilities = ["gpu", "compute", "utility", "video", "graphics"]
  }

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York",
    "NVIDIA_VISIBLE_DEVICES=all",
    "NVIDIA_DRIVER_CAPABILITIES=all",
    "PIXELFLUX_WAYLAND=true",
    "DRINODE=/dev/dri/renderD128",
    "DRI_NODE=/dev/dri/renderD128"
  ]

  # STORAGE: Pointing to your ~/services/retroarch structure
  mounts {
    target = "/config"
    source = "/home/chris/services/retroarch/config"
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts, security_opts]
  }
}