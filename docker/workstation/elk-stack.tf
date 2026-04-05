
# ── Network ─────────────────────────────────────────────────
resource "docker_network" "elk" {
  provider     = docker.workstation
  name   = "elk"
  driver = "bridge"
}

# ── Images ──────────────────────────────────────────────────
resource "docker_image" "elasticsearch" {
  provider     = docker.workstation
  name         = "docker.elastic.co/elasticsearch/elasticsearch:${var.elk_version}"
  keep_locally = true
}

resource "docker_image" "logstash" {
  provider     = docker.workstation
  name         = "docker.elastic.co/logstash/logstash:${var.elk_version}"
  keep_locally = true
}

resource "docker_image" "kibana" {
  provider     = docker.workstation
  name         = "docker.elastic.co/kibana/kibana:${var.elk_version}"
  keep_locally = true
}

resource "docker_image" "alpine" {
  provider     = docker.workstation
  name         = "alpine:latest"
  keep_locally = true
}

# ── Elasticsearch ────────────────────────────────────────────
resource "docker_container" "elasticsearch" {
  provider     = docker.workstation
  name    = "elasticsearch"
  image   = docker_image.elasticsearch.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.elk.name
  }
  # Elasticsearch REST API
  ports {
    internal = 9200
    external = 9200
  }
  # Elasticsearch transport (for clustering - not needed in single-node mode, but we'll expose it anyway)
  ports {
    internal = 9300
    external = 9300
  }

  mounts {
    target = "/usr/share/elasticsearch/data"
    source = var.elasticsearch_data_path
    type   = "bind"
  }

  env = [
    "discovery.type=single-node",
    "xpack.security.enabled=false",
    "ES_JAVA_OPTS=${var.es_java_opts}"
  ]

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:9200"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "30s"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}

# ── Logstash ─────────────────────────────────────────────────
resource "docker_container" "logstash" {
  provider     = docker.workstation
  name    = "logstash"
  image   = docker_image.logstash.image_id
  restart = "unless-stopped"

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
    "LS_JAVA_OPTS=${var.ls_java_opts}"
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

# ── Kibana ───────────────────────────────────────────────────
resource "docker_container" "kibana" {
  provider     = docker.workstation
  name    = "kibana"
  image   = docker_image.kibana.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.elk.name
  }

  ports {
    internal = 5601
    external = 5601
  }

  env = [
    "ELASTICSEARCH_HOSTS=http://elasticsearch:9200",
    "LOGGING_ROOT_LEVEL=warn",
    "SERVER_PUBLICBASEURL=https://kibana.${var.homlab_domain}"
  ]

  depends_on = [docker_container.elasticsearch]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
