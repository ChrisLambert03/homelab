resource "docker_image" "beszel_agent" {
  provider     = docker.workstation
  name         = "henrygd/beszel-agent-nvidia:${var.beszel_agent_version}"
  keep_locally = true
}

# ─── Beszel Agent ─────────────────────────────────────────────────────────────

resource "docker_container" "beszel_agent" {
  provider     = docker.workstation
  name         = "beszel-agent"
  image        = docker_image.beszel_agent.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  runtime      = "nvidia"

  env = [
    "LISTEN=45876",
    "KEY=${var.beszel_key}",
    "TOKEN=${var.beszel_token}",
    "HUB_URL=https://beszel.${var.homlab_domain}",
    "NVIDIA_VISIBLE_DEVICES=all",
    "NVIDIA_DRIVER_CAPABILITIES=utility"
  ]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    host_path      = "/home/chris/services/beszel/beszel-agent/beszel_agent_data"
    container_path = "/var/lib/beszel-agent"
  }

  # Extra drives for monitoring
  volumes {
    host_path      = "/mnt/blue_drive/.beszel"
    container_path = "/extra-filesystems/disk1"
    read_only      = true
  }

  volumes {
    host_path      = "/mnt/black_drive/.beszel"
    container_path = "/extra-filesystems/disk2"
    read_only      = true
  }

  # NVIDIA GPU support
  device_requests {
    driver       = "nvidia"
    count        = -1
    capabilities = ["utility"]
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
