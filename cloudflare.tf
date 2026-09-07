# Fetch the Cloudflare Zone for lambertlab.us
data "cloudflare_zone" "main" {
  filter = {
    name = "lambertlab.us"
  }
}

# Wildcard A Records for each k3s node Tailscale IP (HA Direct Ingress)
resource "cloudflare_dns_record" "wildcard_workstation" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  content = data.tailscale_device.workstation.addresses[0]
  type    = "A"
  ttl     = 300
  proxied = false
  comment = "k3s workstation - Managed by Terraform"
}

resource "cloudflare_dns_record" "wildcard_opti74" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  content = data.tailscale_device.opti74.addresses[0]
  type    = "A"
  ttl     = 300
  proxied = false
  comment = "k3s opti74 - Managed by Terraform"
}

resource "cloudflare_dns_record" "wildcard_optiplex" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  content = data.tailscale_device.optiplex.addresses[0]
  type    = "A"
  ttl     = 300
  proxied = false
  comment = "k3s optiplex - Managed by Terraform"
}

resource "cloudflare_dns_record" "wildcard_lenovo" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  content = data.tailscale_device.lenovo.addresses[0]
  type    = "A"
  ttl     = 300
  proxied = false
  comment = "k3s lenovo - Managed by Terraform"
}

