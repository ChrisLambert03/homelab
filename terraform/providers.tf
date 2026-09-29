# Configure the Docker provider to connect to a remote Docker host via TCP
provider "docker" {
  alias     = "workstation"
  host      = "tcp://${local.workstation_ip}:2376"
  cert_path = pathexpand("~/.docker")
}

# provider on lenovo ip via TCP
provider "docker" {
  alias     = "lenovo"
  host      = "tcp://${local.lenovo_thinkcentre_ip}:2376"
  cert_path = pathexpand("~/.docker")
}

# provider on optiplex ip via native TLS
provider "docker" {
  alias     = "optiplex"
  host      = "tcp://${local.optiplex9020_ip}:2376"
  cert_path = pathexpand("~/.docker")
}
# Configuration-based authentication
# provider "nginxproxymanager" {
#   url      = "http://${local.workstation_ip}:81"
#   username = local.npm_user
#   password = local.npm_password
# }
# The libvirt provider is configured to connect to a remote host via SSH.
provider "libvirt" {
  uri = "qemu+ssh://${local.ssh_user}@${local.workstation_ip}/system"
}
# Hashicorp Vault provider configuration
provider "vault" {
  # It is recommended to set these via VAULT_ADDR and VAULT_TOKEN env vars instead
  address = "https://vault.lambertlab.us"
  token   = var.vault_password
}

# Tailscale provider configuration
provider "tailscale" {
  tailnet = var.tailscale_tailnet
  api_key = local.tailscale_api_key
}

# Cloudflare provider configuration
provider "cloudflare" {
  api_token = local.cloudflare_api_token
}

# Active Directory provider configuration for Windows Server DC01
provider "ad" {
  winrm_hostname = "winrm.lambertlab.us"
  winrm_username = "svc_terraform@lambertlab.us"
  winrm_password = local.ad_svc_terraform_password
  winrm_port     = 443
  winrm_proto    = "https"
  winrm_insecure = false
}