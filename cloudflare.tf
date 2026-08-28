# Fetch the Cloudflare Zone for lambertlab.us
data "cloudflare_zone" "main" {
  filter = {
    name = "lambertlab.us"
  }
}

# Wildcard A Record dynamically pointing to the Tailscale k8s-gateway Service IPv4
resource "cloudflare_dns_record" "wildcard" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  content = data.tailscale_service.k8s_gateway.addrs[0]
  type    = "A"
  ttl     = 300
  proxied = false
  comment = "Kubernetes VIP - Managed by Terraform"
}
