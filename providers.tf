# Configure the Docker provider to connect to a remote Docker host via SSH
provider "docker" {
  alias    = "workstation"
  host     = "ssh://${local.ssh_user}@${local.workstation_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
#provider on lenvovo ip
provider "docker" {
  alias    = "lenovo"
  host     = "ssh://${local.ssh_user}@${local.lenovo_thinkcentre_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
# provider on optiplex ip
provider "docker" {
  alias    = "optiplex"
  host     = "ssh://${local.ssh_user}@${local.optiplex9020_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
# Configuration-based authentication
provider "nginxproxymanager" {
  url      = "http://${local.workstation_ip}:81"
  username = local.npm_user
  password = local.npm_password
}
# The libvirt provider is configured to connect to a remote host via SSH.
provider "libvirt" {
  uri = "qemu+ssh://${local.ssh_user}@${local.workstation_ip}/system"
}
# Hashicorp Vault provider configuration
provider "vault" {
  # It is recommended to set these via VAULT_ADDR and VAULT_TOKEN env vars instead
  address = "http://${var.vault_ip}:8200"
  token   = var.vault_password
}