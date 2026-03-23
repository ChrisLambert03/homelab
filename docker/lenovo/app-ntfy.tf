resource "docker_image" "ntfy" {
  provider     = docker.lenovo
  name         = "binwiederhier/ntfy:latest"
  keep_locally = true
}

resource "docker_container" "ntfy" {
  provider = docker.lenovo
  name     = "ntfy"
  image    = docker_image.ntfy.image_id
  restart  = "unless-stopped"
  command  = ["serve"]

  env = [
    "TZ=America/New_York"
  ]

  ports {
    internal = 80
    external = 2323
  }

  volumes {
    host_path      = "/home/chris/services/ntfy/var/cache/ntfy"
    container_path = "/var/cache/ntfy"
  }

  volumes {
    host_path      = "/home/chris/services/ntfy/etc/ntfy"
    container_path = "/etc/ntfy"
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget -q --tries=1 http://localhost:80/v1/health -O - | grep -Eo '\"healthy\"\\s*:\\s*true' || exit 1"]
    interval     = "1m0s"
    timeout      = "10s"
    retries      = 3
    start_period = "40s"
  }
}