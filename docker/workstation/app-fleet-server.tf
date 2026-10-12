# ── Images ──────────────────────────────────────────────────
data "docker_registry_image" "elastic_agent" {
  name = "docker.elastic.co/elastic-agent/elastic-agent:${var.elk_version}"
}

resource "docker_image" "elastic_agent" {
  provider      = docker.workstation
  name          = data.docker_registry_image.elastic_agent.name
  pull_triggers = [data.docker_registry_image.elastic_agent.sha256_digest]
  keep_locally  = false
}

# ── Fleet Server ─────────────────────────────────────────────
# The central management daemon for Elastic Agents across Kubernetes and bare-metal nodes.
resource "docker_container" "fleet_server" {
  provider = docker.workstation
  name     = "fleet-server"
  image    = docker_image.elastic_agent.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.elk.name
  }

  ports {
    internal = 8220
    external = 8220
  }

  env = [
    "FLEET_SERVER_ENABLE=true",
    "FLEET_SERVER_ELASTICSEARCH_HOST=http://elasticsearch:9200",
    "FLEET_SERVER_SERVICE_TOKEN=${var.fleet_server_service_token}",
    "FLEET_SERVER_POLICY_ID=fleet-server-policy",
    "FLEET_SERVER_PORT=8220",
    "FLEET_URL=https://100.106.96.18:8220",
    "FLEET_INSECURE=true",
  ]

  depends_on = [
    docker_container.elasticsearch,
  ]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
