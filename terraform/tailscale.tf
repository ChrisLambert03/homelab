data "tailscale_device" "workstation" {
  name = "workstation.${var.tailscale_tailnet}"
}

data "tailscale_device" "opti74" {
  name = "opti74.${var.tailscale_tailnet}"
}

data "tailscale_device" "optiplex" {
  name = "optiplex.${var.tailscale_tailnet}"
}

data "tailscale_device" "opti76" {
  name = "opti76.${var.tailscale_tailnet}"
}

