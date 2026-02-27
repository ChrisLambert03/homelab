
variable "workstation_ip" {
  type = string
}

variable "homlab_domain" {
  type = string
}

variable "optiplex7040_ip" {
  type = string
}

variable "optiplex9020_ip" {
  type = string
}

variable "lenovo_thinkcentre_ip" {
  type = string
}

variable "wildcard_cert_id" {
  type = number
}

variable "nginx_manager_container_id" {
  type = string
  description = "(optional) id of the nginx-proxy-manager container to ensure ordering"
  default = null
}

