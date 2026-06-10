data "docker_registry_image" "portainer" {
  name = "portainer/portainer-ce:lts"
}

resource "docker_image" "portainer" {
  provider      = docker.optiplex
  name          = data.docker_registry_image.portainer.name
  pull_triggers = [data.docker_registry_image.portainer.sha256_digest]
  keep_locally  = false
}

resource "docker_container" "portainer" {
  provider = docker.optiplex
  name     = "portainer"
  image    = docker_image.portainer.image_id
  restart  = "always"

  ports {
    internal = 8000
    external = 8000
  }

  ports {
    internal = 9000
    external = 9000
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    volume_name    = var.portainer_volume_name
    container_path = "/data"
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
  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}