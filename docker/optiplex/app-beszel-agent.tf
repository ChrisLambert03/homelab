data "docker_registry_image" "beszel_agent" {
  name = "henrygd/beszel-agent-intel:${var.beszel_agent_version}"
}

resource "docker_image" "beszel_agent" {
  provider      = docker.optiplex
  name          = data.docker_registry_image.beszel_agent.name
  pull_triggers = [data.docker_registry_image.beszel_agent.sha256_digest]
  keep_locally  = false
}

# ─── Beszel Agent ─────────────────────────────────────────────────────────────

resource "docker_container" "beszel_agent" {
  provider     = docker.optiplex
  name         = "beszel-agent"
  image        = docker_image.beszel_agent.image_id
  restart      = "unless-stopped"
  network_mode = "host"

  env = [
    "LISTEN=45876",
    "KEY=${var.beszel_key}",
    "TOKEN=${var.beszel_token}",
    "HUB_URL=https://beszel.${var.homelab_domain}"
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

  devices {
    host_path      = "/dev/dri/card1"
    container_path = "/dev/dri/card1"
  }

  capabilities {
    add = ["CAP_PERFMON"]
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
