# Runbook: ELK Stack (Elasticsearch, Logstash, Kibana) & Single-Node Index Lifecycle Management (ILM)

This runbook documents operational maintenance, health verification, Index Lifecycle Management (ILM) policies, and troubleshooting procedures for the **LambertLab** centralized ELK Stack (Elasticsearch, Logstash, Kibana) and Security Information and Event Management (SIEM) platform.

---

## ⚠️ The Problem: Single-Node Elasticsearch Cluster Health (`YELLOW`)

### Symptoms
* Elasticsearch cluster health reports `status: "yellow"`:
  ```bash
  curl -s -u elastic:<password> "http://workstation:9200/_cluster/health?pretty"
  ```
* Output displays `unassigned_shards > 0`.
* Automated Index Lifecycle Management (ILM) policies fail to advance indices from Hot to Warm, Cold, or Delete phases.
* Indices accumulate indefinitely, leading to disk space exhaustion on `workstation` NVMe storage.

### Root Cause Diagnosis
By default, Elasticsearch index templates configure indices with `number_of_replicas: 1`. In a single-node cluster (configured with `discovery.type=single-node`), there is only one node (`workstation`). Elasticsearch refuses to allocate a replica shard on the same physical node as the primary shard, leaving the replica permanently unassigned. Because the cluster cannot fulfill its replica policy, its health status degrades to **`YELLOW`**, causing ILM retention and rollover automation to stall.

---

## 🛠️ Operational Resolution: Enforcing `number_of_replicas: 0`

### Step 1: Update Existing Indices Immediately
Run the following REST command to immediately strip replica requirements across all active indices:

```bash
curl -X PUT -u elastic:<password> "http://workstation:9200/*/_settings" \
  -H "Content-Type: application/json" \
  -d '{
    "index": {
      "number_of_replicas": 0
    }
  }'
```

Within seconds, the unassigned shards will clear and cluster health will transition to **`GREEN`**:

```bash
curl -s -u elastic:<password> "http://workstation:9200/_cluster/health?pretty" | grep "status"
# Expected output: "status" : "green"
```

---

### Step 2: Configure Global Component Template for Future Indices
To ensure all future daily indices (`homelab-logs-YYYY.MM.dd`) are created with zero replicas out of the box, apply a high-priority index template:

```bash
curl -X PUT -u elastic:<password> "http://workstation:9200/_index_template/homelab_single_node_template" \
  -H "Content-Type: application/json" \
  -d '{
    "index_patterns": ["homelab-logs-*", "*"],
    "priority": 500,
    "template": {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "refresh_interval": "5s"
      }
    }
  }'
```

---

## 🔍 Testing Ingestion Pipelines

### 1. Verifying Docker GELF over Tailscale (Port 12201)
To test whether Logstash is actively accepting GELF logs over the Tailscale network mesh, send a test payload using Python or Netcat from any cluster node (`lenovo`, `optiplex`, or `opti74`):

```bash
# Send a test GELF UDP packet to Logstash on workstation
echo '{"version": "1.1", "host": "test-node", "short_message": "GELF test ping", "level": 6}' | nc -u -w 1 workstation 12201
```

Confirm ingestion by querying the most recent documents in Elasticsearch:

```bash
curl -s -u elastic:<password> "http://workstation:9200/homelab-logs-*/_search?q=GELF+test+ping&pretty"
```

### 2. Inspecting Logstash Pipeline Status
Check Logstash container logs on `workstation`:

```bash
docker --context workstation-engine logs -f logstash --tail 50
```
Healthy output should confirm active input on `0.0.0.0:12201` (GELF UDP/TCP) with zero pipeline worker exceptions.

---

## 💾 Storage Hygiene & Data Pruning

* **Storage Path:** Local workstation NVMe at `/usr/share/elasticsearch/data`.
* **Prohibition:** Never configure Elasticsearch data paths targeting 1Gbps network iSCSI or NFS shares.
* **Emergency Index Deletion:** If workstation disk space drops below 15% and immediate pruning is necessary:
  ```bash
  # Delete indices older than 30 days
  curl -X DELETE -u elastic:<password> "http://workstation:9200/homelab-logs-2026.08.*"
  ```
