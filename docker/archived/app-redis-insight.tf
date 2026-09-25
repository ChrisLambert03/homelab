data "docker_registry_image" "redisinsight" {
  name = "redis/redisinsight:latest"
}

resource "docker_image" "redisinsight" {
  provider      = docker.workstation
  name          = data.docker_registry_image.redisinsight.name
  pull_triggers = [data.docker_registry_image.redisinsight.sha256_digest]
  keep_locally  = false
}

resource "docker_volume" "redisinsight_data" {
  provider = docker.workstation
  name     = "redisinsight_data"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "docker_container" "redisinsight" {
  provider = docker.workstation
  name     = "redisinsight"
  image    = docker_image.redisinsight.image_id
  restart  = "unless-stopped"

  ports {
    internal = 5540
    external = 5540
  }

  volumes {
    volume_name    = docker_volume.redisinsight_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.redis_net.name
  }

  depends_on = [
    docker_container.redis
  ]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}