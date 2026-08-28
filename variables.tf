variable "portainer_volume_name" {
  description = "Name of the Portainer data volume"
  type        = string
  default     = "portainer_data"
}


variable "vault_password" {
  description = "Hashicorp Vault root token"
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet" {
  description = "Tailscale tailnet name"
  type        = string
  sensitive   = true
}
