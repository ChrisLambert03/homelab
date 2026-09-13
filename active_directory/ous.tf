# ==============================================================================
# ENTERPRISE ORGANIZATIONAL UNITS (OU HIERARCHY)
# ==============================================================================

# 1. Primary Organization Root OU
resource "ad_ou" "lambertlab" {
  name        = "LambertLab"
  path        = "DC=ad,DC=lambertlab,DC=us"
  description = "Primary Enterprise Root OU for LambertLab"
  protected   = true
}

# 2. Privileged Administrators
resource "ad_ou" "admins" {
  name        = "Admins"
  path        = ad_ou.lambertlab.dn
  description = "Privileged administrative accounts"
  protected   = true
}

# 3. Infrastructure & Linux/Windows Servers
resource "ad_ou" "servers" {
  name        = "Servers"
  path        = ad_ou.lambertlab.dn
  description = "Infrastructure servers, K8s nodes, and storage"
  protected   = true
}

# 4. Client Desktops & Workstations
resource "ad_ou" "desktops" {
  name        = "Desktops"
  path        = ad_ou.lambertlab.dn
  description = "Client desktop computers and laptops"
  protected   = true
}

# 5. Standard User Accounts
resource "ad_ou" "users" {
  name        = "Users"
  path        = ad_ou.lambertlab.dn
  description = "Standard human user accounts"
  protected   = true
}

# 6. Enterprise Security Groups
resource "ad_ou" "groups" {
  name        = "Security Groups"
  path        = ad_ou.lambertlab.dn
  description = "Role-based access control and security groups"
  protected   = true
}

# 7. Application & Integration Service Accounts
resource "ad_ou" "service_accounts" {
  name        = "Service Accounts"
  path        = ad_ou.lambertlab.dn
  description = "Service accounts for OPNsense, Vault, and automation"
  protected   = true
}
