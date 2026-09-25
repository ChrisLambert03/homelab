
resource "docker_network" "redis_net" {
  provider = docker.workstation
  name     = "n8n-redis-net"
  driver   = "bridge"
}

data "docker_registry_image" "redis" {
  name = "redis:latest"
}

resource "docker_image" "redis" {
  provider      = docker.workstation
  name          = data.docker_registry_image.redis.name
  pull_triggers = [data.docker_registry_image.redis.sha256_digest]
  keep_locally  = false
}

resource "docker_volume" "redis_data" {
  provider = docker.workstation
  name     = "redis_data"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "docker_container" "redis" {
  provider = docker.workstation
  name     = "redis"
  image    = docker_image.redis.image_id
  restart  = "unless-stopped"
  # sets redis to save the DB to disk if at least 1 key changes within 300 seconds (5 minutes)
  command = [
    "redis-server",
    "--save", "300", "1",
    "--loglevel", "warning",
  ]

  ports {
    internal = 6379
    external = 6379
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.redis_net.name
  }

  healthcheck {
    test         = ["CMD", "redis-cli", "ping"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "5s"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}