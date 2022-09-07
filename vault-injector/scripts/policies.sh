#!/bin/bash
#
# Setup

realpath() {
  cd "$1" || echo "$1"
  pwd
  cd - >/dev/null || echo "$1"
}

createSharedSecretsPolicies() {

  # Bridge API secret policies
  cat <<EOF >"$DATA_DIR"/policy-shared-bridge-read.hcl

path "secret/shared/bridge/bridge-api-auth" {
  capabilities = ["read"]
}

path "secret/data/shared/bridge/bridge-api-auth" {
  capabilities = ["read"]
}

EOF

  cat <<EOF >"$DATA_DIR"/policy-shared-bridge-write.hcl

path "secret/shared/bridge/bridge-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

path "secret/data/shared/bridge/bridge-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

EOF

  # Maxmind API secret policies
  cat <<EOF >"$DATA_DIR"/policy-shared-maxmind-read.hcl

path "secret/shared/maxmind/maxmind-api-auth" {
  capabilities = ["read"]
}

path "secret/data/shared/maxmind/maxmind-api-auth" {
  capabilities = ["read"]
}

EOF

  cat <<EOF >"$DATA_DIR"/policy-shared-maxmind-write.hcl

path "secret/shared/maxmind/maxmind-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

path "secret/data/shared/maxmind/maxmind-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

EOF

}

# ----
# Per environment secrets
# ---
createEnvironmentsPolicies() {
  # LYRA API key - production
  cat <<EOF >"$DATA_DIR"/policy-shared-lyra-production-write.hcl
path "secret/shared/lyra/environments/production/lyra-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "secret/data/shared/lyra/environments/production/lyra-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF

  cat <<EOF >"$DATA_DIR"/policy-shared-lyra-production-read.hcl
path "secret/shared/lyra/environments/production/lyra-api-auth" {
  capabilities = ["read"]
}
path "secret/data/shared/lyra/environments/production/lyra-api-auth" {
  capabilities = ["read"]
}
EOF

  # LYRA API key - development
  cat <<EOF >"$DATA_DIR"/policy-shared-lyra-development-write.hcl
path "secret/shared/lyra/environments/development/lyra-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "secret/data/shared/lyra/environments/development/lyra-api-auth" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF

  cat <<EOF >"$DATA_DIR"/policy-shared-lyra-development-read.hcl
path "secret/shared/lyra/environments/development/lyra-api-auth" {
  capabilities = ["read"]
}
path "secret/data/shared/lyra/environments/development/lyra-api-auth" {
  capabilities = ["read"]
}
EOF

  # S3 API AK/SK - production
  cat <<EOF >"$DATA_DIR"/policy-shared-awss3pleenk-production-write.hcl
path "secret/shared/aws-s3-pleenk-data/environments/production/aws-s3-pleenk-data" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF

  cat <<EOF >"$DATA_DIR"/policy-shared-awss3pleenk-production-read.hcl
path "secret/shared/aws-s3-pleenk-data/environments/production/aws-s3-pleenk-data" {
  capabilities = [ "read"]
}
path "secret/data/shared/aws-s3-pleenk-data/environments/production/aws-s3-pleenk-data" {
  capabilities = [ "read"]
}
EOF

  # S3 API AK/SK - development
  cat <<EOF >"$DATA_DIR"/policy-shared-awss3pleenk-development-write.hcl
path "secret/shared/aws-s3-pleenk-data/environments/development/aws-s3-pleenk-data" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "secret/data/shared/aws-s3-pleenk-data/environments/development/aws-s3-pleenk-data" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF

  cat <<EOF >"$DATA_DIR"/policy-shared-awss3pleenk-development-read.hcl
path "secret/shared/aws-s3-pleenk-data/environments/development/aws-s3-pleenk-data" {
  capabilities = ["read"]
}
path "secret/data/shared/aws-s3-pleenk-data/environments/development/aws-s3-pleenk-data" {
  capabilities = ["read"]
}
EOF
}

createPerEnvironmentPolicies() {
  environment=$1
  if [[ -n $2 ]]; then
    filename_environment=$2
  else
    filename_environment=$environment
  fi

  for application in bff auth marketplace; do

    cat <<EOF >"$DATA_DIR/policy-infra-$filename_environment-internals-$application-write.hcl"
path "secret/environments/$environment/internals/$application/$application-jwt-sign-private" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "secret/data/environments/$environment/internals/$application/$application-jwt-sign-private" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF
    cat <<EOF >"$DATA_DIR/policy-infra-$filename_environment-internals-$application-read.hcl"
path "secret/environments/$environment/internals/$application/$application-jwt-sign-private" {
  capabilities = ["read"]
}
path "secret/data/environments/$environment/internals/$application/$application-jwt-sign-private" {
  capabilities = ["read"]
}
EOF

    cat <<EOF >"$DATA_DIR/policy-infra-$filename_environment-internals-$application-shared-write.hcl"
path "secret/environments/$environment/internals/shared/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "secret/data/environments/$environment/internals/shared/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF
    cat <<EOF >"$DATA_DIR/policy-infra-$filename_environment-internals-$application-shared-read.hcl"
path "secret/environments/$environment/internals/shared/*" {
  capabilities = ["read"]
}
path "secret/data/environments/$environment/internals/shared/*" {
  capabilities = ["read"]
}
EOF

  done

}

# MAIN
SCRIPT_DIR="$(dirname "$0")"
DATA_DIR="$(realpath "$SCRIPT_DIR"/../data)"
CONFIG_DIR=$DATA_DIR/config

mkdir -p "$CONFIG_DIR"

find "$DATA_DIR" -name 'policy*.hcl' -delete

createSharedSecretsPolicies

createEnvironmentsPolicies

for environment in production ci; do
  createPerEnvironmentPolicies $environment
done

createPerEnvironmentPolicies '{{identity.entity.aliases.gitlab.id}}' developer

# ---

VAULT_ADDR=${VAULT_ADDR:-http://localhost:8200}
VAULT_TOKEN=${VAULT_TOKEN:-$(jq -r ".root_token" "$CONFIG_DIR"/cluster-keys.json)}

export VAULT_ADDR VAULT_TOKEN
find "$DATA_DIR" -name 'policy*.hcl' | xargs -tn1 -I{} /bin/bash -c 'vault policy write $(basename "$1" .hcl) "$1"' - {}
