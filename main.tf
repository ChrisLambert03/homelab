# Call the docker applications module
module "docker_apps" {
  source = "./docker"

  workstation_ip          = var.workstation_ip
  ssh_user                = var.ssh_user
  jellyfin_config_path    = var.jellyfin_config_path
  jellyfin_cache_path     = var.jellyfin_cache_path
  blue_drive_path         = var.blue_drive_path
  black_drive_path        = var.black_drive_path
  nginx_data_path         = var.nginx_data_path
  nginx_letsencrypt_path  = var.nginx_letsencrypt_path
  npm_user                = var.npm_user
  npm_password            = var.npm_password
  homlab_domain           = var.homlab_domain
  wildcard_cert_id        = var.wildcard_cert_id
  optiplex7040_ip         = var.optiplex7040_ip
  optiplex9020_ip         = var.optiplex9020_ip
  lenovo_thinkcentre_ip   = var.lenovo_thinkcentre_ip
}

# call the libvirt module
module "libvirt" {
  source = "./vms"
 # workstation_ip          = var.workstation_ip
#  ssh_user                = var.ssh_user
}