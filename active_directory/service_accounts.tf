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
