# ── Images ──────────────────────────────────────────────────
data "docker_registry_image" "logstash" {
  name = "docker.elastic.co/logstash/logstash:${var.elk_version}"
}

resource "docker_image" "logstash" {
  provider      = docker.workstation
  name          = data.docker_registry_image.logstash.name
  pull_triggers = [data.docker_registry_image.logstash.sha256_digest]
  keep_locally  = false
}

# ── Logstash ─────────────────────────────────────────────────
# The ETL (Extract, Transform, Load) engine. 
# Processes container logs from Docker GELF before sending to Elasticsearch.
resource "docker_container" "logstash" {
  provider = docker.workstation
  name     = "logstash"
  image    = docker_image.logstash.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.elk.name
  }

  # GELF UDP
  ports {
    internal = 12201
    external = 12201
    protocol = "udp"
  }

  # GELF TCP
  ports {
    internal = 12201
    external = 12201
    protocol = "tcp"
  }

  env = [
    "LS_JAVA_OPTS=${var.ls_java_opts}",
    "ELASTIC_PASSWORD=${var.elastic_password}"
  ]

  volumes {
    host_path      = var.logstash_conf_path
    container_path = "/usr/share/logstash/pipeline/logstash.conf"
    read_only      = true
  }

  depends_on = [docker_container.elasticsearch]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
