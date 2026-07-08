
# ── Network ─────────────────────────────────────────────────
resource "docker_network" "elk" {
  provider = docker.workstation
  name     = "elk"
  driver   = "bridge"
}

# ── Images ──────────────────────────────────────────────────
data "docker_registry_image" "elasticsearch" {
  name = "docker.elastic.co/elasticsearch/elasticsearch:${var.elk_version}"
}

resource "docker_image" "elasticsearch" {
  provider      = docker.workstation
  name          = data.docker_registry_image.elasticsearch.name
  pull_triggers = [data.docker_registry_image.elasticsearch.sha256_digest]
  keep_locally  = false
}

data "docker_registry_image" "logstash" {
  name = "docker.elastic.co/logstash/logstash:${var.elk_version}"
}

resource "docker_image" "logstash" {
  provider      = docker.workstation
  name          = data.docker_registry_image.logstash.name
  pull_triggers = [data.docker_registry_image.logstash.sha256_digest]
  keep_locally  = false
}

data "docker_registry_image" "kibana" {
  name = "docker.elastic.co/kibana/kibana:${var.elk_version}"
}

resource "docker_image" "kibana" {
  provider      = docker.workstation
  name          = data.docker_registry_image.kibana.name
  pull_triggers = [data.docker_registry_image.kibana.sha256_digest]
  keep_locally  = false
}

# ── Elasticsearch ────────────────────────────────────────────
# The core search and analytics engine. Configured as a single-node 
# cluster with optimized memory for homelab use.
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
# The ETL (Extract, Transform, Load) engine. 
# Processes logs from GELF and Filebeat before sending to Elasticsearch.
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

# ── Kibana ───────────────────────────────────────────────────
# The visualization dashboard for exploring and analyzing logs.
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

    # Optimization: Increase the Node.js memory limit for Kibana to 2GB. 
    # This prevents UI timeouts when querying large amounts of log data (like Jellyfin streams).
    "NODE_OPTIONS=--max-old-space-size=2048",

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

