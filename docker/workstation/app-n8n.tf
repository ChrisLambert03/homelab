
resource "docker_image" "n8n" {
  name         = "docker.n8n.io/n8nio/n8n:latest"
  keep_locally = true
}

resource "docker_container" "n8n" {
  name         = "n8n"
  image        = docker_image.n8n.image_id
  restart      = "unless-stopped"
  network_mode = "host"

  env = [
    "N8N_HOST=n8n.${var.homlab_domain}",
    "WEBHOOK_URL=https://n8n.${var.homlab_domain}",
    "GENERIC_TIMEZONE=America/New_York",
    "N8N_ENCRYPTION_KEY=${var.n8n_key}",
  ]
  #replace with mounts
  mounts {
    target = "/home/node/.n8n"
    source = "/home/chris/services/n8n/"
    type   = "bind"
  }

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}