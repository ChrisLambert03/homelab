variable "workstation_ip" {
  type        = string
  description = "The IP address of your Thinkmate workstation"
  sensitive   = true
}
variable "ssh_user" {
  type        = string
  description = "SSH user for the Thinkmate workstation"
  sensitive   = true
}
variable "jellyfin_config_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin config and metadata is stored"
  sensitive   = true
}
variable "blue_drive_path" {
  type        = string
  description = "Path on the Thinkmate where blue drive media is stored"
  sensitive   = true
}
variable "black_drive_path" {
  type        = string
  description = "Path on the Thinkmate where black drive media is stored"
  sensitive   = true
}

variable "jellyfin_cache_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin cache is stored"
  sensitive   = true
}

variable "nginx_data_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager data (SQLite DB and config) is stored"
  sensitive   = true
}

variable "nginx_letsencrypt_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager SSL certificates (Let's Encrypt) are stored"
  sensitive   = true
}

variable "npm_user" {
  type        = string
  description = "Username for Nginx Proxy Manager"
  sensitive   = true
}

variable "npm_password" {
  type        = string
  description = "Password for Nginx Proxy Manager"
  sensitive   = true
}


variable "homlab_domain" {
  type        = string
  description = "Domain used for the homelab services"
  sensitive   = true
}

variable "wildcard_cert_id" {
  type        = number
  description = "ID of the wildcard certificate in Nginx Proxy Manager to use for the homelab domain"
  sensitive   = true
}

variable "optiplex7040_ip" {
  type        = string
  description = "The IP address of the Optiplex 7040 (if used for additional services)"
  sensitive   = true
}

variable "optiplex9020_ip" {
  type        = string
  description = "The IP address of the Optiplex 9020 (if used for additional services)"
  sensitive   = true
}

variable "lenovo_thinkcentre_ip" {
  type        = string
  description = "The IP address of the Lenovo ThinkCentre (if used for additional services)"
  sensitive   = true
}

variable "jellyfin_macvlan_ip" {
  type        = string
  description = "IP address for the jellyfin container on the macvlan network"
  sensitive   = true
}

variable "access_list_id" {
  type        = number
  description = "ID of the access list in Nginx Proxy Manager to use for the homelab services)"
  sensitive   = true
}