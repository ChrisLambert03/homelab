resource "nginxproxymanager_access_list" "personal_access_list" {
  name = "Personal Access List"

  access = [
    {
      directive = "allow"
      address   = var.laptop_ip
    },
    {
      directive = "allow"
      address   = var.phone_ip
    }
  ]

  pass_auth   = false
  satisfy_any = true
}