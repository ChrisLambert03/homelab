
resource "docker_network" "redis_net" {
  name   = "n8n-redis-net"
  driver = "bridge"
}

resource "docker_image" "redis" {
  name         = "redis:latest"
  keep_locally = true
}

resource "docker_volume" "redis_data" {
  name = "redis_data"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "docker_container" "redis" {
  name    = "redis"
  image   = docker_image.redis.image_id
  restart = "unless-stopped"
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
}