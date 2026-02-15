# 1. Image for Nginx Proxy Manager
resource "docker_image" "nginx_proxy_manager" {
  name         = "jc21/nginx-proxy-manager:latest"
  keep_locally = true
}

# 2. Nginx Proxy Manager Container
resource "docker_container" "nginx_proxy_manager" {
  name    = "nginx-proxy-manager"
  image   = docker_image.nginx_proxy_manager.image_id
  restart = "unless-stopped"

  # Host mode means it uses the Thinkmate's IP directly.
  # maps 80, 443, and 81 automatically to the host
  network_mode = "host"
  env = [
    "TZ=America/New_York",
  ]

  # Data Storage (SQLite DB and config)
  mounts {
    target = "/data"
    source = var.nginx_data_path
    type   = "bind"
  }

  # SSL Certificates (Let's Encrypt)
  mounts {
    target = "/etc/letsencrypt"
    source = var.nginx_letsencrypt_path
    type   = "bind"
  }
}

data "nginxproxymanager_certificate" "certificate" {
  id = 2
}

resource "nginxproxymanager_proxy_host" "jellyfin_proxy" {
  domain_names = ["jellyfin.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.workstation_ip
  forward_port   = 8096

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
}

resource "nginxproxymanager_proxy_host" "firefox_proxy" {
  domain_names = ["firefox.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.optiplex7040_ip
  forward_port   = 4000

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true 
}

resource "nginxproxymanager_proxy_host" "portainer_proxy" {
  domain_names = ["portainer.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.optiplex9020_ip
  forward_port   = 9000

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
}

resource "nginxproxymanager_proxy_host" "sonarr_proxy" {
  domain_names = ["sonarr.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.workstation_ip
  forward_port   = 8989

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true 
}

resource "nginxproxymanager_proxy_host" "radarr_proxy" {
  domain_names = ["radarr.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.workstation_ip
  forward_port   = 7878

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true 
}

resource "nginxproxymanager_proxy_host" "prowlarr_proxy" {
  domain_names = ["prowlarr.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.workstation_ip
  forward_port   = 9696

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
  
}

resource "nginxproxymanager_proxy_host" "tdarr_proxy" {
  domain_names = ["tdarr.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.workstation_ip
  forward_port   = 8265

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
  
}

resource "nginxproxymanager_proxy_host" "nginx_proxy" {
  domain_names = ["nginx.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.workstation_ip
  forward_port   = 81

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
  
}

resource "nginxproxymanager_proxy_host" "grafana_proxy" {
  domain_names = ["grafana.${var.homlab_domain}"]

  forward_scheme = "http"
  forward_host   = var.lenovo_thinkcentre_ip
  forward_port   = 3030

  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true

  certificate_id  = var.wildcard_cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
  
}