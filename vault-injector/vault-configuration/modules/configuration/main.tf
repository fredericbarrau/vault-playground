# Enable kubernetes auth
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_host
  issuer                 = "api"
  disable_iss_validation = "true"
}

# Setup secret engine
resource "vault_mount" "sercrets" {
  path        = "secret"
  type        = "kv-v2"
  description = "KV Version 2 secret engine mount"
}

