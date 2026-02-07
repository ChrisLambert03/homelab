variable "workstation_ip" {
  type        = string
  description = "The IP address of your Thinkmate workstation"
}
variable "ssh_user" {
  type        = string
  description = "SSH user for the Thinkmate workstation"
}
variable "jellyfin_config_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin config and metadata is stored"
}
variable "blue_drive_path" {
  type        = string
  description = "Path on the Thinkmate where blue drive media is stored"
}
variable "black_drive_path" {
  type        = string
  description = "Path on the Thinkmate where black drive media is stored"
}

variable "jellyfin_cache_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin cache is stored"
}

variable "nginx_data_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager data (SQLite DB and config) is stored"
}

variable "nginx_letsencrypt_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager SSL certificates (Let's Encrypt) are stored"
}

variable "npm_user" {
  type        = string
  description = "Username for Nginx Proxy Manager"
}

variable "npm_password" {
  type        = string
  description = "Password for Nginx Proxy Manager"
}


variable "homlab_domain" {
  type        = string
  description = "Domain used for the homelab services"
}

variable "wildcard_cert_id" {
  type        = number
  description = "ID of the wildcard certificate in Nginx Proxy Manager to use for the homelab domain"
}

variable "optiplex7040_ip" {
  type        = string
  description = "The IP address of the Optiplex 7040 (if used for additional services)"
}

variable "optiplex9020_ip" {
  type        = string
  description = "The IP address of the Optiplex 9020 (if used for additional services)"
}

variable "lenovo_thinkcentre_ip" {
  type        = string
  description = "The IP address of the Lenovo ThinkCentre (if used for additional services)"
}