# Enable kubernetes auth
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}
#
# Kubernetes cluster that can be accessed by Vault can use
# Kubernetes auth from vault as vault will be able to validate the JWT token against the
# kube API.

# Using the client's JWT token to validate the token against Kubernetes TokenReview API
# See https://www.vaultproject.io/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt
resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  # disable_iss_validation = "true"
  # This auth method by default expect to run on a kubernetes pod and re-use the CA and auth from the 
  # current kube cluster

}

# Isolated kunbernetes clusters (or local development clusters) must use the approle auth method
# to authenticate against vault

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "developer_application" {
  backend            = vault_auth_backend.approle.path
  role_name          = "developer-application-role"
  secret_id_num_uses = 0
  token_policies     = ["default", "dev-secrets-read", "shared-secrets-read"]
}

#
# Setup secret engine
#
resource "vault_mount" "secrets" {
  path        = "secret"
  type        = "kv-v2"
  description = "KV Version 2 secret engine mount"
}

# Define two secrets :
resource "vault_kv_secret_v2" "shared_secret" {
  mount               = vault_mount.secrets.path
  name                = "shared-secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      secret = "global secret shared to all policies",
      foo    = "bar"
    }
  )
}

resource "vault_kv_secret_v2" "dev_secret" {
  mount               = vault_mount.secrets.path
  name                = "dev-secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      secret = "secret for a developer",
      foo    = "baz"
    }
  )
}

# Define 2 policies
resource "vault_policy" "dev_write" {
  name = "dev-secrets-write"

  policy = <<EOT
path "secret/dev-secret" {
  capabilities = ["create","update","delete","read","list"]
}
path "secret/data/dev-secret" {
  capabilities = ["create","update","delete","read","list"]
}
EOT
}

resource "vault_policy" "shared_write" {
  name = "shared-secrets-write"

  policy = <<EOT
path "secret/shared-secret" {
  capabilities = ["create","update","delete","read","list"]
}
path "secret/data/shared-secret" {
  capabilities = ["create","update","delete","read","list"]
}
EOT
}

resource "vault_policy" "dev_read" {
  name = "dev-secrets-read"

  policy = <<EOT
path "secret/dev-secret" {
  capabilities = ["read"]
}
path "secret/data/dev-secret" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "shared_read" {
  name = "shared-secrets-read"

  policy = <<EOT
path "secret/shared-secret" {
  capabilities = ["read"]
}
path "secret/data/shared-secret" {
  capabilities = ["read"]
}
EOT
}

# Policy for managing the developer application role
# This policy should be provided to a developer account (human) or the CI administrator
resource "vault_policy" "approle_developer_read" {
  name = "dev-secrets-read"

  policy = <<EOT
# Read/Write developer roles information
path "auth/approle/developer" {
  capabilities = [ "read",  ]
}
path "auth/approle/developer/role" {
  capabilities = [ "read", "update", "list" ]
}
# Get the roleid for the approle
path "auth/approle/developer/role/*" {
  capabilities = [ "read", "update", "list" ]
}
EOT
}
