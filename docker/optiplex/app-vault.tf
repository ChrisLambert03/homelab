resource "docker_image" "vault" {
  provider     = docker.optiplex
  name         = "hashicorp/vault:${var.vault_version}"
  keep_locally = true
}

# ─── Network ──────────────────────────────────────────────────────────────────

resource "docker_network" "vault_net" {
  provider = docker.optiplex
  name     = "vault_net"
  driver   = "bridge"
}

# ─── Vault (Production Mode) ──────────────────────────────────────────────────

resource "docker_container" "vault" {
  provider = docker.optiplex
  name     = "vault-prod"
  image    = docker_image.vault.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.vault_net.name
  }
  
  env = [
    "VAULT_ADDR=http://0.0.0.0:8200",
  ]

  ports {
    internal = 8200
    external = 8222
  }

  # Config mount
  volumes {
    host_path      = var.vault_config_path
    container_path = "/vault/config/vault.hcl"
    read_only      = true
  }

  # Data mount
  volumes {
    host_path      = var.vault_data_path
    container_path = "/vault/data"
    read_only      = false
  }

  # Secrets JSON mount (for bootstrap/auto-load if needed)
  volumes {
    host_path      = var.vault_secrets_path
    container_path = "/vault/config/secrets.json"
    read_only      = true
  }

  entrypoint = ["vault", "server", "-config=/vault/config/vault.hcl"]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}

# ─── Vault Auto-Unseal Sidecar ───────────────────────────────────────────────

resource "docker_container" "vault_unsealer" {
  provider = docker.optiplex
  name     = "vault-unsealer"
  image    = docker_image.vault.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.vault_net.name
  }

  env = [
    "VAULT_ADDR=http://vault-prod:8200",
  ]

  # Using a simple shell loop to monitor and unseal
  entrypoint = [
    "sh", "-c",
    "while true; do if vault status 2>&1 | grep -q 'Sealed.*true'; then echo 'Vault is sealed. Unsealing...'; vault operator unseal ${var.vault_unseal_keys[0]}; vault operator unseal ${var.vault_unseal_keys[1]}; vault operator unseal ${var.vault_unseal_keys[2]}; fi; sleep 30; done"
  ]

  depends_on = [docker_container.vault]

  lifecycle {
    ignore_changes = [log_driver, log_opts]
  }
}
