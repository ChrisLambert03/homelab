# Homelab Ansible

This directory contains the Ansible playbooks, roles, and inventory configurations used to bootstrap, harden, and maintain the physical nodes and infrastructure base of the homelab.

## 🏗️ Architecture & Inventory

- **Inventory (`homelab-nodes`)**: Defines the physical nodes in the cluster. Nodes are logically grouped by role (e.g., `control_planes`, `workers`, `gpu_nodes`) to target playbooks accurately.
- **`ansible.cfg`**: Configures default execution behaviors, roles path, host key checking, and inventory source.

## 🔒 Vault & Secrets Integration

Ansible playbooks interact with sensitive data (certificates, API tokens). Ensure your local environment is authenticated or that you provide the necessary vault decryption passwords when running playbooks. 

*If using `ansible-vault`, ensure your `.vault_pass` file is securely located and referenced in your environment.*

## 🚀 Playbooks & Bootstrapping Order

When provisioning a bare-metal node from scratch, playbooks should generally be executed in the following order to resolve dependencies:

### 1. Base Node Configuration
- **`tools.yml`**: Installs essential system utilities (curl, vim, htop, etc.).
- **`fix-node-networking.yml` / `fix-e1000e-driver.yml`**: Handles specific host network card quirks or driver bugs (e.g., Intel NIC dropouts).

### 2. Storage & Virtualization Prerequisites
- **`longhorn-reqs.yml`**: Prepares nodes for Longhorn CSI (configures `multipathd` to ignore Longhorn virtual devices).
- **`configure-iscsi.yml`**: Sets up iSCSI initiators (`iscsid`) with custom timeouts to connect safely to the TerraMaster NAS block targets. 

### 3. Container Runtimes & PKI
- **`generate-certs.yml` / `deploy-certs.yml`**: Automates PKI generation and distribution for node-level TLS services.
- **`configure-docker.yml` / `configure-docker-tls-gelf.yml`**: Configures Docker daemons across nodes, opens TCP 2376 with TLS, and enforces centralized GELF logging to Logstash.
- **`restart-docker.yml`**: Safely restarts daemons after configuration changes.

### 4. Routine Maintenance
- **`update.yml`**: Triggers `apt update && apt upgrade` across the fleet.

## 🛠️ Execution Conventions

### Prerequisites
Before running playbooks, ensure all required Ansible Galaxy collections are installed:
```bash
ansible-galaxy collection install -r requirements.yml
```

### Running Playbooks
To run a playbook locally, ensure you are in the `ansible/` directory:

```bash
# Run updates across the entire inventory
ansible-playbook -i homelab-nodes update.yml

# Target a specific playbook against a specific node (e.g., workstation)
ansible-playbook -i homelab-nodes configure-docker.yml --limit workstation
```

### Linting
Before committing changes, ensure your YAML syntax and Ansible structures pass linting:
```bash
ansible-lint .
```
