# ─── Network ───────────────────────────────────────────────────────────────────

resource "docker_network" "guacamole" {
  provider = docker.lenovo
  name     = "guacamole_net"
  driver   = "bridge"
}


# ─── Images ────────────────────────────────────────────────────────────────────

resource "docker_image" "guacd" {
  provider     = docker.lenovo
  name         = "guacamole/guacd:${var.guacamole_version}"
  keep_locally = true
}

resource "docker_image" "guacamole" {
  provider     = docker.lenovo
  name         = "guacamole/guacamole:${var.guacamole_version}"
  keep_locally = true
}

resource "docker_image" "postgres" {
  provider     = docker.lenovo
  name         = "postgres:${var.postgres_version}"
  keep_locally = true
}

# ─── PostgreSQL ────────────────────────────────────────────────────────────────

resource "docker_container" "postgres" {
  provider = docker.lenovo
  name     = "guacamole_postgres"
  image    = docker_image.postgres.image_id
  restart  = "unless-stopped"

  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "PGDATA=/var/lib/postgresql/data/guacamole",
  ]

  volumes {
    host_path      = "/home/chris/services/guacamole/postgres"
    container_path = "/var/lib/postgresql/data"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }

  networks_advanced {
    name = docker_network.guacamole.name
  }
}

# ─── guacd ─────────────────────────────────────────────────────────────────────

resource "docker_container" "guacd" {
  provider = docker.lenovo
  name     = "guacd"
  image    = docker_image.guacd.image_id
  restart  = "unless-stopped"

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }

  networks_advanced {
    name = docker_network.guacamole.name
  }
}

# ─── Guacamole web app ─────────────────────────────────────────────────────────

resource "docker_container" "guacamole" {
  provider = docker.lenovo
  name     = "guacamole"
  image    = docker_image.guacamole.image_id
  restart  = "unless-stopped"

  env = [
    "GUACD_HOSTNAME=guacd",
    "POSTGRESQL_HOSTNAME=${docker_container.postgres.name}",
    "POSTGRESQL_DATABASE=${var.postgres_db}",
    "POSTGRESQL_USER=${var.postgres_user}",
    "POSTGRESQL_PASSWORD=${var.postgres_password}",
    "WEBAPP_CONTEXT=ROOT",
    "TOTP_ENABLED=${var.totp_enabled}",
  ]

  ports {
    internal = 8080
    external = var.guacamole_port
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }

  networks_advanced {
    name = docker_network.guacamole.name
  }

  depends_on = [
    docker_container.guacd,
    docker_container.postgres,
  ]
}