# ==============================================================================
# HUMAN USER ACCOUNTS
# ==============================================================================

resource "ad_user" "chris" {
  display_name           = "Chris Lambert"
  principal_name         = "chris@lambertlab.us"
  sam_account_name       = "chris"
  given_name             = "Chris"
  surname                = "Lambert"
  email_address          = "chris@lambertlab.us"
  container              = ad_ou.users.dn
  enabled                = true
  password_never_expires = true
  description            = "Homelab Architect & Systems Administrator"

  lifecycle {
    ignore_changes = [initial_password]
  }
}
