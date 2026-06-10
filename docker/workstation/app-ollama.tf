data "docker_registry_image" "ollama" {
  name = "ollama/ollama:latest"
}

resource "docker_image" "ollama" {
  provider      = docker.workstation
  name          = data.docker_registry_image.ollama.name
  pull_triggers = [data.docker_registry_image.ollama.sha256_digest]
  keep_locally  = false
}

resource "docker_container" "ollama" {
  provider = docker.workstation
  name     = "ollama"
  image    = docker_image.ollama.image_id
  restart  = "unless-stopped"

  gpus = "all"

  ports {
    internal = 11434
    external = 11434
  }

  volumes {
    volume_name    = "ollama"
    container_path = "/root/.ollama"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
