# Enable userpass auth
resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
}
