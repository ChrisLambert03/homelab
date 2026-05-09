terraform {
  cloud {
    organization = "hcp-lambertlab-us"
    hostname     = "app.terraform.io"
    workspaces {
      project = "homelab-project"
      name    = "homelab-workspace"
    }
  }
}
