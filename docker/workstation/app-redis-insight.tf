resource "docker_image" "redisinsight" {
  name         = "redis/redisinsight:latest"
  keep_locally = true
}

resource "docker_volume" "redisinsight_data" {
  name = "redisinsight_data"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "docker_container" "redisinsight" {
  name    = "redisinsight"
  image   = docker_image.redisinsight.image_id
  restart = "unless-stopped"

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
}