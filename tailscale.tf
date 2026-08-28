# Fetch Tailscale Service details for the Kubernetes Ingress Gateway
data "tailscale_service" "k8s_gateway" {
  name = "svc:k8s-gateway"
}

# Dynamically retrieved Service IPv4 address
output "k8s_gateway_ipv4" {
  description = "Tailscale Service IPv4 address for k8s-gateway"
  value       = data.tailscale_service.k8s_gateway.addrs[0]
}
