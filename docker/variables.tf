variable "jellyfin_config_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin config and metadata is stored"
}

variable "jellyfin_cache_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin cache is stored"
}

variable "blue_drive_path" {
  type        = string
  description = "Path on the Thinkmate where blue drive media is stored"
}

variable "black_drive_path" {
  type        = string
  description = "Path on the Thinkmate where black drive media is stored"
}

variable "nginx_data_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager data (SQLite DB and config) is stored"
}

variable "nginx_letsencrypt_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager SSL certificates (Let's Encrypt) are stored"
}

variable "jellyfin_macvlan_ip" {
  type        = string
  description = "IP address for the jellyfin container on the macvlan network"
}

variable "n8n_encryption_key" {
  type        = string
  description = "Encryption key for n8n. Must be exactly 32 characters long."
}

variable "homlab_domain" {
  type        = string
  description = "Domain name for the homelab (e.g. homelab.local)"
}