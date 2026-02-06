# Pull Jellyfin Image
resource "docker_image" "jellyfin" {
  name         = "jellyfin/jellyfin:latest"
  keep_locally = true # Don't delete the image after creating the container (on destroy)
}