# ==============================================================================
# INTEGRATION SERVICE ACCOUNTS
# ==============================================================================

# Terraform Active Directory Automation Service Account
resource "ad_user" "svc_terraform" {
  display_name           = "Terraform Automation Service Account"
  principal_name         = "svc_terraform@lambertlab.us"
  sam_account_name       = "svc_terraform"
  container              = ad_ou.service_accounts.dn
  initial_password       = var.ad_svc_terraform_password
  enabled                = true
  password_never_expires = true
  description            = "Automation service account for Terraform Active Directory management"

  lifecycle {
    ignore_changes = [initial_password, cannot_change_password]
  }
}

# Guacamole LDAP Directory Search Service Account
resource "ad_user" "svc_guacamole" {
  display_name           = "Guacamole LDAP Service Account"
  principal_name         = "svc_guacamole@lambertlab.us"
  sam_account_name       = "svc_guacamole"
  container              = ad_ou.service_accounts.dn
  initial_password       = var.ad_svc_guacamole_password
  enabled                = true
  password_never_expires = true
  description            = "Read-only bind account for Apache Guacamole Active Directory authentication"

  lifecycle {
    ignore_changes = [initial_password, cannot_change_password]
  }
}

# Domain Join Service Account for Workstations/Desktops
resource "ad_user" "svc_domainjoin" {
  display_name           = "Domain Join Service Account"
  principal_name         = "svc_domainjoin@lambertlab.us"
  sam_account_name       = "svc_domainjoin"
  container              = ad_ou.service_accounts.dn
  initial_password       = var.ad_svc_domainjoin_password
  enabled                = true
  password_never_expires = true
  description            = "Restricted service account for joining workstations and clients to Active Directory"

  lifecycle {
    ignore_changes = [initial_password, cannot_change_password]
  }
}
