variable "ad_svc_terraform_password" {
  description = "Password for svc_terraform service account"
  type        = string
  sensitive   = true
}

variable "ad_svc_guacamole_password" {
  description = "Password for svc_guacamole service account"
  type        = string
  sensitive   = true
}

variable "ad_svc_domainjoin_password" {
  description = "Password for svc_domainjoin service account"
  type        = string
  sensitive   = true
}
