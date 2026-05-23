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