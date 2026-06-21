/* Migrated to Kubernetes ###
variable "homarr_secret_key" {
  description = "Homarr secret encryption key"
  type        = string
  sensitive   = true
}

variable "homarr_log_level" {
  description = "Homarr log level "
  type        = string
  default     = "error"
}
*/
# ─── Image versions ────────────────────────────────────────────────────────────

variable "guacamole_version" {
  description = "Guacamole / guacd image tag"
  type        = string
  default     = "1.6.0"
}

variable "postgres_version" {
  description = "PostgreSQL image tag"
  type        = string
  default     = "17-alpine"
}

variable "beszel_version" {
  description = "Beszel image tag"
  type        = string
  default     = "latest"
}

variable "beszel_agent_version" {
  description = "Beszel agent image tag"
  type        = string
  default     = "latest"
}

# ─── PostgreSQL credentials ────────────────────────────────────────────────────

variable "postgres_db" {
  description = "Guacamole database name"
  type        = string
  default     = "guacamole_db"
}

variable "postgres_user" {
  description = "Guacamole database user"
  type        = string
  default     = "guacamole_user"
}

variable "postgres_password" {
  description = "Guacamole database password"
  type        = string
  sensitive   = true
}

# ─── App settings ──────────────────────────────────────────────────────────────

variable "guacamole_port" {
  description = "Host port to expose the Guacamole web UI on"
  type        = number
  default     = 8223
}

variable "totp_enabled" {
  description = "Enable TOTP two-factor authentication"
  type        = string
  default     = "false"
}

variable "beszel_port" {
  description = "Host port to expose Beszel on"
  type        = number
  default     = 8090
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