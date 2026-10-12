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

  mounts {
    target = "/usr/share/elasticsearch/snapshots"
    source = "/home/chris/services/elasticsearch/snapshots"
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
    "path.repo=/usr/share/elasticsearch/snapshots",
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
