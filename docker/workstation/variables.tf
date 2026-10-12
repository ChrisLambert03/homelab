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





variable "jellyfin_macvlan_ip" {
  type        = string
  description = "IP address for the jellyfin container on the macvlan network"
}



variable "homlab_domain" {
  type        = string
  description = "Domain name for the homelab (e.g. homelab.local)"
}

variable "beszel_key" {
  description = "Beszel agent public key"
  type        = string
  sensitive   = true
}

variable "beszel_token" {
  description = "Beszel agent token"
  type        = string
  sensitive   = true
}

variable "tdarr_auth_key" {
  description = "Authentication secret key for Tdarr"
  type        = string
  sensitive   = true
}

variable "beszel_agent_version" {
  description = "Beszel agent image tag"
  type        = string
  default     = "latest"
}


