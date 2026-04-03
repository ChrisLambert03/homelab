# Configure the Docker provider to connect to a remote Docker host via SSH
provider "docker" {
  host     = "ssh://${var.ssh_user}@${var.workstation_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
#provider on lenvovo ip
provider "docker" {
  alias    = "lenovo"
  host     = "ssh://${var.ssh_user}@${var.lenovo_thinkcentre_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# Configuration-based authentication
provider "nginxproxymanager" {
  url      = "http://${var.workstation_ip}:81"
  username = var.npm_user
  password = var.npm_password
}
# The libvirt provider is configured to connect to a remote host via SSH.
provider "libvirt" {
  uri = "qemu+ssh://${var.ssh_user}@${var.workstation_ip}/system"
}