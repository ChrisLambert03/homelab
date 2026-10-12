data "docker_registry_image" "kibana" {
  name = "docker.elastic.co/kibana/kibana:${var.elk_version}"
}

resource "docker_image" "kibana" {
  provider      = docker.workstation
  name          = data.docker_registry_image.kibana.name
  pull_triggers = [data.docker_registry_image.kibana.sha256_digest]
  keep_locally  = false
}

### Migrated to Kubernetes (ECK Operator in observability namespace) ###

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
