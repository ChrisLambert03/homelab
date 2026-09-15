# ==============================================================================
# ENTERPRISE SECURITY GROUPS
# ==============================================================================

# Core directory administrative groups (Domain Admins) are managed natively
# within Active Directory to protect built-in administrative accounts.

resource "ad_group" "opnsense_admins" {
  name             = "OPNsense-Admins"
  sam_account_name = "OPNsense-Admins"
  scope            = "global"
  category         = "security"
  container        = ad_ou.groups.dn
  description      = "OPNsense Firewall Administrators"
}

resource "ad_group_membership" "opnsense_admins" {
  group_id = ad_group.opnsense_admins.id
  group_members = [
    ad_user.chris.id
  ]
}

resource "ad_group" "guacamole_admins" {
  name             = "Guacamole-Admins"
  sam_account_name = "Guacamole-Admins"
  scope            = "global"
  category         = "security"
  container        = ad_ou.groups.dn
  description      = "Apache Guacamole Gateway Administrators"
}

resource "ad_group_membership" "guacamole_admins" {
  group_id = ad_group.guacamole_admins.id
  group_members = [
    ad_user.chris.id
  ]
}


