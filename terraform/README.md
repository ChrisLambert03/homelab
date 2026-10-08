# Homelab Terraform

This directory contains the declarative Terraform configurations used to provision and manage the infrastructure and security layers of the LambertLab ecosystem.

## 🏗️ Architecture & State Backend

- **State Backend**: Terraform state is managed remotely via HashiCorp Cloud Platform (HCP). Refer to `backend.tf` and `terraform.tf` for HCP workspace configurations.
- **Provider Architectures (`providers.tf`)**:
  - **Cloudflare**: Manages DNS records (`cloudflare.tf`) and domain verification for `lambertlab.us`.
  - **Tailscale**: Manages Tailnet ACLs, subnet routing, and exit node configurations (`tailscale.tf`).
  - **HashiCorp Vault**: Configures secrets engines, access policies, and AppRoles (`vault.tf`) for Kubernetes consumption.
  - **Active Directory**: Declaratively manages on-prem Active Directory users, groups, and OUs via WinRM (`active_directory/`).
  - **Docker**: Manages containerized host workloads on standalone nodes (`docker/`).

## 🔒 Variables and Secrets Management

Sensitive variables are strictly excluded from version control. 

- **`variables.tf`**: Declares variables used throughout the configurations.
- **`terraform.tfvars`**: Provides local overrides. **Never commit this file.**

**Required Environment Variables:**
Before executing Terraform, ensure your shell environment is primed with the necessary tokens:
```bash
export TF_API_TOKEN="<your-hcp-token>"
export VAULT_TOKEN="<your-vault-root-token>"
export TAILSCALE_TAILNET="lambertlab.us"
```

## 🛠️ Execution Conventions

To execute operations locally, navigate to the `terraform/` directory.

### Prerequisites
1. Log in to HCP: `terraform login`
2. Ensure you have the required CLI tools: `terraform`, `tflint`.

### Workflow
```bash
# 1. Initialize the backend and download providers
terraform init

# 2. Validate syntax and structural configuration
terraform validate

# 3. Plan changes to review state drift
terraform plan

# 4. Apply changes (requires explicit 'yes' approval)
terraform apply
```

### Pre-Commit Hooks
Before committing any changes, you must format your configuration and run the linter to ensure best practices:
```bash
terraform fmt -check -recursive
tflint --recursive
```
