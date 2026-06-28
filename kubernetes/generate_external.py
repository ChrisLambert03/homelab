import os

apps = [
    {"name": "beszel", "ip": "100.95.104.11", "port": 8090, "scheme": "http"},
    {"name": "firefox", "ip": "100.65.236.98", "port": 4000, "scheme": "http"},
    {"name": "portainer", "ip": "100.74.145.55", "port": 9000, "scheme": "http"},
    {"name": "tdarr", "ip": "100.106.96.18", "port": 8265, "scheme": "http"},
    {"name": "n8n", "ip": "100.106.96.18", "port": 5678, "scheme": "http"},
    {"name": "redisinsight", "ip": "100.106.96.18", "port": 5540, "scheme": "http"},
    {"name": "kibana", "ip": "100.106.96.18", "port": 5601, "scheme": "http"},
    {"name": "guacamole", "ip": "100.95.104.11", "port": 8223, "scheme": "http"},
    {"name": "retroarch", "ip": "100.106.96.18", "port": 3005, "scheme": "http"},
    {"name": "nas", "ip": "10.0.0.60", "port": 8181, "scheme": "http"},
    {"name": "cockpit", "ip": "100.106.96.18", "port": 9090, "scheme": "https"}
]

for app in apps:
    os.makedirs(f"/home/chris/homelab/kubernetes/{app['name']}", exist_ok=True)
    
    # Service and EndpointSlice
    service_annotations = ""
    if app['scheme'] == 'https':
        service_annotations = """
  annotations:
    traefik.ingress.kubernetes.io/service.serversscheme: https
    traefik.ingress.kubernetes.io/service.serverstransport: default-insecure-transport@kubernetescrd"""

    service_yaml = f"""apiVersion: v1
kind: Service
metadata:
  name: {app['name']}
  namespace: default{service_annotations}
spec:
  ports:
    - port: {app['port']}
      targetPort: {app['port']}
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: {app['name']}
  namespace: default
  labels:
    kubernetes.io/service-name: {app['name']}
addressType: IPv4
ports:
  - port: {app['port']}
endpoints:
  - addresses:
      - "{app['ip']}"
"""
    with open(f"/home/chris/homelab/kubernetes/{app['name']}/service.yaml", "w") as f:
        f.write(service_yaml)

    # Ingress
    ingress_yaml = f"""apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {app['name']}-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.middlewares: default-https-redirect@kubernetescrd,default-admin-only-access@kubernetescrd
spec:
  ingressClassName: traefik
  rules:
  - host: {app['name']}.lambertlab.us
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {app['name']}
            port:
              number: {app['port']}
  tls:
  - hosts:
    - {app['name']}.lambertlab.us
    secretName: lambertlab-wildcard-tls
"""
    with open(f"/home/chris/homelab/kubernetes/{app['name']}/ingress.yaml", "w") as f:
        f.write(ingress_yaml)
