variable "workstation_ip" {
  type        = string
  description = "The IP address of your Thinkmate workstation"
}
variable "ssh_user" {
  type        = string
  description = "SSH user for the Thinkmate workstation"
}
variable "jellyfin_config_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin config and metadata is stored"
}
variable "blue_drive_path" {
  type        = string
  description = "Path on the Thinkmate where blue drive media is stored"
}
variable "black_drive_path" {
  type        = string
  description = "Path on the Thinkmate where black drive media is stored"
}

variable "jellyfin_cache_path" {
  type        = string
  description = "Path on the Thinkmate where jellyfin cache is stored"
}
