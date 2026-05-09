
resource "docker_image" "beszel" {
  provider     = docker.lenovo
  name         = "henrygd/beszel:${var.beszel_version}"
  keep_locally = true
}

# ─── Beszel ────────────────────────────────────────────────────────────────────

resource "docker_container" "beszel" {
  provider = docker.lenovo
  name     = "beszel"
  image    = docker_image.beszel.image_id
  restart  = "unless-stopped"

  env = [
    "APP_URL=https://beszel.${var.homelab_domain}"
  ]

  ports {
    internal = 8090
    external = var.beszel_port
  }

  volumes {
    host_path      = "/home/chris/services/beszel/beszel_data"
    container_path = "/beszel_data"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
