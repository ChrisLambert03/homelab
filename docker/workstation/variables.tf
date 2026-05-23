variable "jellyfin_config_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin config and metadata is stored"
}

variable "jellyfin_cache_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin cache is stored"
}

variable "blue_drive_path" {
  type        = string
  description = "Path on the Thinkmate where blue drive media is stored"
}

variable "black_drive_path" {
  type        = string
  description = "Path on the Thinkmate where black drive media is stored"
}

variable "wd_drive_path" {
  type        = string
  description = "Path on the Thinkmate where wd drive media is stored"
}

variable "nginx_data_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager data (SQLite DB and config) is stored"
}

variable "nginx_letsencrypt_path" {
  type        = string
  description = "Path on the Thinkmate where nginx proxy manager SSL certificates (Let's Encrypt) are stored"
}

variable "jellyfin_macvlan_ip" {
  type        = string
  description = "IP address for the jellyfin container on the macvlan network"
}

variable "n8n_key" {
  type        = string
  description = "Encryption key for n8n. Must be exactly 32 characters long."
}

variable "homlab_domain" {
  type        = string
  description = "Domain name for the homelab (e.g. homelab.local)"
}

variable "beszel_key" {
  description = "Beszel agent public key"
  type        = string
  sensitive   = true
}

variable "beszel_token" {
  description = "Beszel agent token"
  type        = string
  sensitive   = true
}

variable "beszel_agent_version" {
  description = "Beszel agent image tag"
  type        = string
  default     = "latest"
}

############# elk test vars

variable "elk_version" {
  description = "Version pinned across all ELK images"
  default     = "9.3.2"
  type        = string
}

variable "logstash_conf_path" {
  description = "Absolute path to logstash.conf on your host"
  default     = "/home/chris/services/elk/logstash/logstash.conf"
  type        = string
}

variable "es_java_opts" {
  description = "Elasticsearch JVM heap"
  default     = "-Xms16g -Xmx16g"
  type        = string
}

variable "ls_java_opts" {
  description = "Logstash JVM heap"
  default     = "-Xms1g -Xmx1g"
  type        = string
}

variable "elasticsearch_data_path" {
  description = "Absolute path to elasticsearch data directory on your host"
  default     = "/home/chris/services/elk/elasticsearch"
  type        = string
}

variable "elastic_password" {
  description = "Password for the elastic user in Elasticsearch"
  type        = string
  sensitive   = true
}

variable "kibana_secret_key" {
  description = "Kibana secret encryption key"
  type        = string
  sensitive   = true
}

variable "kibana_system_password" {
  description = "Password for the kibana_system user in Elasticsearch"
  type        = string
  default     = "homelabpassword"
}
