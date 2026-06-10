# 1. Image for Nginx Proxy Manager
data "docker_registry_image" "nginx_proxy_manager" {
  name = "jc21/nginx-proxy-manager:latest"
}

resource "docker_image" "nginx_proxy_manager" {
  provider      = docker.workstation
  name          = data.docker_registry_image.nginx_proxy_manager.name
  pull_triggers = [data.docker_registry_image.nginx_proxy_manager.sha256_digest]
  keep_locally  = false
}

# 2. Nginx Proxy Manager Container
resource "docker_container" "nginx_proxy_manager" {
  provider = docker.workstation
  name     = "nginx-proxy-manager"
  image    = docker_image.nginx_proxy_manager.image_id
  restart  = "unless-stopped"

  # Host mode means it uses the Thinkmate's IP directly.
  # maps 80, 443, and 81 automatically to the host
  network_mode = "host"
  env = [
    "TZ=America/New_York",
  ]

  # Data Storage (SQLite DB and config)
  mounts {
    target = "/data"
    source = var.nginx_data_path
    type   = "bind"
  }

  # SSL Certificates (Let's Encrypt)
  mounts {
    target = "/etc/letsencrypt"
    source = var.nginx_letsencrypt_path
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}

