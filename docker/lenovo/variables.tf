variable "homarr_secret_key" {
  description = "Homarr secret encryption key"
  type        = string
  sensitive   = true
}

variable "homarr_log_level" {
  description = "Homarr log level "
  type        = string
  default     = "warn"
}

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