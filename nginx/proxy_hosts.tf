

resource "nginxproxymanager_proxy_host" "jellyfin_proxy" {
  domain_names            = ["jellyfin.${var.homlab_domain}"]
  access_list_id          = var.access_list_id_2 # jellyfin access list
  forward_scheme          = "http"
  forward_host            = var.jellyfin_macvlan_ip
  forward_port            = 8096
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "firefox_proxy" {
  domain_names            = ["firefox.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.optiplex7040_ip
  forward_port            = 4000
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "portainer_proxy" {
  domain_names            = ["portainer.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.optiplex9020_ip
  forward_port            = 9000
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "sonarr_proxy" {
  domain_names            = ["sonarr.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 8989
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "radarr_proxy" {
  domain_names            = ["radarr.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 7878
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "prowlarr_proxy" {
  domain_names            = ["prowlarr.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 9696
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "tdarr_proxy" {
  domain_names            = ["tdarr.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 8265
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "nginx_proxy" {
  domain_names            = ["nginx.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 81
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "grafana_proxy" {
  domain_names            = ["grafana.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.lenovo_thinkcentre_ip
  forward_port            = 3030
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "homarr_proxy" {
  domain_names            = ["homarr.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.lenovo_thinkcentre_ip
  forward_port            = 7575
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "ntfy_proxy" {
  domain_names = ["ntfy.${var.homlab_domain}"]

  forward_scheme          = "http"
  forward_host            = var.lenovo_thinkcentre_ip
  forward_port            = 2323
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "cockpit_proxy" {
  domain_names            = ["cockpit.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "https"
  forward_host            = var.workstation_ip
  forward_port            = 9090
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

resource "nginxproxymanager_proxy_host" "n8n_proxy" {
  domain_names            = ["n8n.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 5678
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}
# redis isnight proxy host
resource "nginxproxymanager_proxy_host" "redis_insight_proxy" {
  domain_names            = ["redisinsight.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 5540
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}
#prometheus proxy host
resource "nginxproxymanager_proxy_host" "prometheus_proxy" {
  domain_names            = ["prometheus.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.lenovo_thinkcentre_ip
  forward_port            = 9090
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

#kibana proxy host
resource "nginxproxymanager_proxy_host" "kibana_proxy" {
  domain_names            = ["kibana.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 5601
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

# guacamole proxy host
resource "nginxproxymanager_proxy_host" "guacamole_proxy" {
  domain_names            = ["guacamole.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.lenovo_thinkcentre_ip
  forward_port            = 8223
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}

#retroarch proxy host
resource "nginxproxymanager_proxy_host" "retroarch_proxy" {
  domain_names            = ["retroarch.${var.homlab_domain}"]
  access_list_id          = var.access_list_id
  forward_scheme          = "http"
  forward_host            = var.workstation_ip
  forward_port            = 3005
  caching_enabled         = true
  allow_websocket_upgrade = true
  block_exploits          = true
  certificate_id          = var.wildcard_cert_id
  ssl_forced              = true
  hsts_enabled            = true
  hsts_subdomains         = true
  http2_support           = true
}
