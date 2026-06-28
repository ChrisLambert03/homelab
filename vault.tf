# Fetch all homelab secrets from Vault KV v2
data "vault_kv_secret_v2" "homelab_secrets" {
  mount = "secret"
  name  = "homelab"
}

# Convert Vault secret data to usable locals
locals {
  # Network IPs
  workstation_ip        = tostring(data.vault_kv_secret_v2.homelab_secrets.data["workstation_ip"])
  optiplex9020_ip       = tostring(data.vault_kv_secret_v2.homelab_secrets.data["optiplex9020_ip"])
  lenovo_thinkcentre_ip = tostring(data.vault_kv_secret_v2.homelab_secrets.data["lenovo_thinkcentre_ip"])
  jellyfin_macvlan_ip   = tostring(data.vault_kv_secret_v2.homelab_secrets.data["jellyfin_macvlan_ip"])

  # Authentication
  ssh_user = tostring(data.vault_kv_secret_v2.homelab_secrets.data["ssh_user"])

  # Encryption & Secret Keys
  n8n_key = tostring(data.vault_kv_secret_v2.homelab_secrets.data["n8n_key"])
  # homarr_secret_key = tostring(data.vault_kv_secret_v2.homelab_secrets.data["homarr_secret_key"]) Migrated to Kubernetes
  kibana_secret_key = tostring(data.vault_kv_secret_v2.homelab_secrets.data["kibana_secret_key"])
  elastic_password  = tostring(data.vault_kv_secret_v2.homelab_secrets.data["elastic_password"])
  postgres_password = tostring(data.vault_kv_secret_v2.homelab_secrets.data["postgres_password"])

  # Configuration
  homlab_domain = tostring(data.vault_kv_secret_v2.homelab_secrets.data["homlab_domain"])

  # Beszel
  beszel_key               = tostring(data.vault_kv_secret_v2.homelab_secrets.data["beszel_key"])
  beszel_token_lenovo      = tostring(data.vault_kv_secret_v2.homelab_secrets.data["beszel_token_lenovo"])
  beszel_token_workstation = tostring(data.vault_kv_secret_v2.homelab_secrets.data["beszel_token_workstation"])
  beszel_token_optiplex    = tostring(data.vault_kv_secret_v2.homelab_secrets.data["beszel_token_optiplex"])

  # Tdarr
  tdarr_auth_key = tostring(data.vault_kv_secret_v2.homelab_secrets.data["tdarr_auth_key"])

  # Paths
  jellyfin_config_path   = tostring(data.vault_kv_secret_v2.homelab_secrets.data["jellyfin_config_path"])
  jellyfin_cache_path    = tostring(data.vault_kv_secret_v2.homelab_secrets.data["jellyfin_cache_path"])
  blue_drive_path        = tostring(data.vault_kv_secret_v2.homelab_secrets.data["blue_drive_path"])
  black_drive_path       = tostring(data.vault_kv_secret_v2.homelab_secrets.data["black_drive_path"])
  wd_drive_path          = tostring(data.vault_kv_secret_v2.homelab_secrets.data["wd_drive_path"])
  nginx_data_path        = tostring(data.vault_kv_secret_v2.homelab_secrets.data["nginx_data_path"])
}
