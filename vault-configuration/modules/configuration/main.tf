# Enable userpass auth
resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
}
# Mount transit secret engine
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Default transit secret engine mount"

  options = {
    convergent_encryption = false
  }
}

# Encryption key for an application
resource "vault_transit_secret_backend_key" "my_application" {
  backend = vault_mount.transit.path
  name    = "my_application"
}
