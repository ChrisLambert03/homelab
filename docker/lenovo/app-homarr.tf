resource "docker_image" "homarr" {
  provider     = docker.lenovo
  name         = "ghcr.io/homarr-labs/homarr:latest"
  keep_locally = true
}

resource "docker_container" "homarr" {
  provider = docker.lenovo
  name     = "homarr"
  image    = docker_image.homarr.image_id
  restart  = "unless-stopped"

  ports {
    internal = 7575
    external = 7575
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "/home/chris/services/homarr/homarr/appdata"
    container_path = "/appdata"
  }
  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    host_path      = "/etc/timezone"
    container_path = "/etc/timezone"
    read_only      = true
  }

  env = [
    "SECRET_ENCRYPTION_KEY=${var.homarr_secret_key}",
    "LOG_LEVEL=${var.homarr_log_level}"
  ]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}