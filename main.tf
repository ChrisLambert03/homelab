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
}

module "lenovo" {
  source = "./docker/lenovo"

  providers = {
    docker.lenovo = docker.lenovo
  }
  # homarr_secret_key = local.homarr_secret_key Migrated to Kubernetes
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