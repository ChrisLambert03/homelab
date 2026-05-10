variable "portainer_volume_name" {
  description = "Name of the Portainer data volume"
  type        = string
  default     = "portainer_data"
}

variable "vault_ip" {
  description = "IP address of the Hashicorp Vault server"
  type        = string
}
variable "vault_password" {
  description = "Hashicorp Vault root token"
  type        = string
  sensitive = true
}