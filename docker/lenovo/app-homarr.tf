resource "docker_image" "homarr" {
  provider = docker.lenovo
  name     = "ghcr.io/homarr-labs/homarr:latest"
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

  env = [
    "SECRET_ENCRYPTION_KEY=${var.homarr_secret_key}"
  ]
}