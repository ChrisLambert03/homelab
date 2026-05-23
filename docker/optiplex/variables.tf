# portainer volume name variable

variable "portainer_volume_name" {
  description = "Name of the Portainer data volume"
  type        = string
}

variable "homelab_domain" {
  description = "Domain used for the homelab services (e.g. example.com)"
  type        = string
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

variable "beszel_agent_version" {
  description = "Beszel agent image tag"
  type        = string
  default     = "latest"
}

# ─── Vault Variables ──────────────────────────────────────────────────────────

variable "vault_secrets_path" {
  description = "Host path to the secrets.json file"
  type        = string
  default     = "/home/chris/services/vault/secrets.json"
}

variable "vault_config_path" {
  description = "Host path to the vault.hcl file"
  type        = string
  default     = "/home/chris/services/vault/vault.hcl"
}

variable "vault_data_path" {
  description = "Host path to the vault persistent data directory"
  type        = string
  default     = "/home/chris/services/vault/data"
}

variable "vault_version" {
  description = "Vault image tag"
  type        = string
  default     = "latest"
}

variable "vault_unseal_keys" {
  description = "List of unseal keys for the production vault"
  type        = list(string)
  sensitive   = true
  default     = []
}
