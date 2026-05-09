# Call the docker applications module
module "docker_apps" {
  source = "./docker/workstation"

  providers = {
    docker.workstation = docker.workstation
  }

  jellyfin_config_path   = var.jellyfin_config_path
  jellyfin_cache_path    = var.jellyfin_cache_path
  jellyfin_macvlan_ip    = var.jellyfin_macvlan_ip
  blue_drive_path        = var.blue_drive_path
  black_drive_path       = var.black_drive_path
  nginx_data_path        = var.nginx_data_path
  wd_drive_path          = var.wd_drive_path
  nginx_letsencrypt_path = var.nginx_letsencrypt_path
  homlab_domain          = var.homlab_domain
  n8n_key                = var.n8n_key
  elastic_password       = var.elastic_password
  kibana_secret_key      = var.kibana_secret_key

}

# Call the optiplex module
module "optiplex" {
  source = "./docker/optiplex"

  providers = {
    docker.optiplex = docker.optiplex
  }

  portainer_volume_name = var.portainer_volume_name
}

module "lenovo" {
  source = "./docker/lenovo"

  providers = {
    docker.lenovo = docker.lenovo
  }
  homarr_secret_key = var.homarr_secret_key
  postgres_password = var.postgres_password
  homelab_domain    = var.homlab_domain

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

  workstation_ip        = var.workstation_ip
  homlab_domain         = var.homlab_domain
  optiplex7040_ip       = var.optiplex7040_ip
  optiplex9020_ip       = var.optiplex9020_ip
  lenovo_thinkcentre_ip = var.lenovo_thinkcentre_ip
  wildcard_cert_id      = var.wildcard_cert_id
  jellyfin_macvlan_ip   = var.jellyfin_macvlan_ip
  access_list_id        = var.access_list_id
  access_list_id_2      = var.access_list_id_2
  pihole_ip =  var.pihole_ip

  # pass through the container id exported by the docker module (optional use)
  #  nginx_manager_container_id = module.docker_apps.nginx_proxy_manager_container_id

  # Ensure the docker module finishes (and the container exists) before creating proxy hosts
  depends_on = [module.docker_apps]
}