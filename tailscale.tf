data "tailscale_device" "workstation" {
  name = "workstation.${var.tailscale_tailnet}"
}

data "tailscale_device" "opti74" {
  name = "opti74.${var.tailscale_tailnet}"
}

data "tailscale_device" "optiplex" {
  name = "optiplex.${var.tailscale_tailnet}"
}

data "tailscale_device" "lenovo" {
  name = "lenovo.${var.tailscale_tailnet}"
}

# Commented out - decommissioned VIP service
# data "tailscale_service" "k8s_gateway" {
#   name = "svc:k8s-gateway"
# }

