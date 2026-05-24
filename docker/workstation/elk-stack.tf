
# ── Network ─────────────────────────────────────────────────
resource "docker_network" "elk" {
  provider = docker.workstation
  name     = "elk"
  driver   = "bridge"
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

resource "docker_image" "filebeat" {
  provider     = docker.workstation
  name         = "docker.elastic.co/beats/filebeat:${var.elk_version}"
  keep_locally = true
}

# ── Elasticsearch ────────────────────────────────────────────
resource "docker_container" "elasticsearch" {
  provider = docker.workstation
  name     = "elasticsearch"
  image    = docker_image.elasticsearch.image_id
  restart  = "unless-stopped"

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
    "ES_JAVA_OPTS=${var.es_java_opts}",
    "xpack.security.enabled=true",
    "xpack.security.authc.api_key.enabled=true",
    "ELASTIC_PASSWORD=${var.elastic_password}",
    # Bypasses the requirement for HTTPS/TLS on local single-node HTTP
    "xpack.security.http.ssl.enabled=false",
  ]

  healthcheck {
    test         = ["CMD", "curl", "-f", "-u", "elastic:${var.elastic_password}", "http://localhost:9200"]
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
  provider = docker.workstation
  name     = "kibana"
  image    = docker_image.kibana.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.elk.name
  }

  ports {
    internal = 5601
    external = 5601
  }

  env = [
    "ELASTICSEARCH_HOSTS=http://elasticsearch:9200",
    "ELASTICSEARCH_USERNAME=kibana_system",
    "ELASTICSEARCH_PASSWORD=${var.kibana_system_password}",
    "LOGGING_ROOT_LEVEL=warn",
    "SERVER_PUBLICBASEURL=https://kibana.${var.homlab_domain}",

    # REQUIRED: Exactly 32+ characters for Fleet/Integrations to load
    "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=${var.kibana_secret_key}",
    "XPACK_REPORTING_ENCRYPTIONKEY=${var.kibana_secret_key}",
    "XPACK_SECURITY_ENCRYPTIONKEY=${var.kibana_secret_key}",
  ]

  depends_on = [docker_container.elasticsearch]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}

# ── Filebeat ──────────────────────────────────────────────────
resource "docker_container" "filebeat" {
  provider = docker.workstation
  name     = "filebeat"
  image    = docker_image.filebeat.image_id
  user     = "1000:1000"
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.elk.name
  }

  # Filebeat Config
  volumes {
    host_path      = "/home/chris/services/elk/filebeat/filebeat.yml"
    container_path = "/usr/share/filebeat/filebeat.yml"
    read_only      = true
  }

  # NPM Logs
  volumes {
    host_path      = var.nginx_data_path
    container_path = "/var/log/npm"
    read_only      = true
  }

  # Sonarr Logs
  volumes {
    host_path      = "/home/chris/services/sonarr/config/logs"
    container_path = "/var/log/sonarr"
    read_only      = true
  }

  # Radarr Logs
  volumes {
    host_path      = "/home/chris/services/radarr/config/logs"
    container_path = "/var/log/radarr"
    read_only      = true
  }

  # Prowlarr Logs
  volumes {
    host_path      = "/home/chris/services/prowlarr/config/logs"
    container_path = "/var/log/prowlarr"
    read_only      = true
  }

  depends_on = [docker_container.logstash]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
