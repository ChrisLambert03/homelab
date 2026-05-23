# Call the docker applications module
module "docker_apps" {
  source = "./docker/workstation"

  providers = {
    docker.workstation = docker.workstation
  }

  jellyfin_config_path   = local.jellyfin_config_path
  jellyfin_cache_path    = local.jellyfin_cache_path
  jellyfin_macvlan_ip    = local.jellyfin_macvlan_ip
  blue_drive_path        = local.blue_drive_path
  black_drive_path       = local.black_drive_path
  nginx_data_path        = local.nginx_data_path
  wd_drive_path          = local.wd_drive_path
  nginx_letsencrypt_path = local.nginx_letsencrypt_path
  homlab_domain          = local.homlab_domain
  n8n_key                = local.n8n_key
  elastic_password       = local.elastic_password
  kibana_secret_key      = local.kibana_secret_key
  beszel_key             = local.beszel_key
  beszel_token           = local.beszel_token_workstation
  tdarr_auth_key         = local.tdarr_auth_key

}

# Call the optiplex module
module "optiplex" {
  source = "./docker/optiplex"

  providers = {
    docker.optiplex = docker.optiplex
  }

  portainer_volume_name = var.portainer_volume_name
  beszel_key            = local.beszel_key
  beszel_token          = local.beszel_token_optiplex
  homelab_domain        = local.homlab_domain
  vault_secrets_path    = "/home/chris/services/vault/secrets.json"
  vault_config_path     = "/home/chris/services/vault/vault.hcl"
  vault_data_path       = "/home/chris/services/vault/data"
  vault_unseal_keys     = var.vault_unseal_keys
}

module "lenovo" {
  source = "./docker/lenovo"

  providers = {
    docker.lenovo = docker.lenovo
  }
  homarr_secret_key = local.homarr_secret_key
  postgres_password = local.postgres_password
  homelab_domain    = local.homlab_domain
  beszel_key        = local.beszel_key
  beszel_token      = local.beszel_token_lenovo

}

# call the libvirt module
module "libvirt" {
  source = "./vms"
  # workstation_ip          = var.workstation_ip
  #  ssh_user                = var.ssh_user
}

# Nginx module: handles Nginx Proxy Manager proxy_host resources
module "nginx" {
  source = "./nginx"

  workstation_ip        = local.workstation_ip
  homlab_domain         = local.homlab_domain
  optiplex7040_ip       = local.optiplex7040_ip
  optiplex9020_ip       = local.optiplex9020_ip
  lenovo_thinkcentre_ip = local.lenovo_thinkcentre_ip
  wildcard_cert_id      = local.wildcard_cert_id
  jellyfin_macvlan_ip   = local.jellyfin_macvlan_ip
  access_list_id        = local.access_list_id
  access_list_id_2      = local.access_list_id_2
  pihole_ip             = local.pihole_ip

  # pass through the container id exported by the docker module (optional use)
  #  nginx_manager_container_id = module.docker_apps.nginx_proxy_manager_container_id

  # Ensure the docker module finishes (and the container exists) before creating proxy hosts
  depends_on = [module.docker_apps]
}