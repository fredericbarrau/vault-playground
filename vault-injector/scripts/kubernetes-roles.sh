#!/bin/bash
#
# Setup roles

realpath() {
  cd "$1" || echo "$1"
  pwd
  cd - >/dev/null || echo "$1"
}

createRoles() {
  environment=$1

  vault write "auth/kubernetes/role/$environment-bff-role" \

    bound_service_account_names=bff-service-account \
    bound_service_account_namespaces="$KUBE_VAULT_NAMESPACE" \
    policies="default,policy-shared-bridge-read,policy-shared-maxmind-read,policy-infra-$environment-internals-bff-read,policy-infra-$environment-internals-auth-shared-read" \
    ttl=1h

  vault write "auth/kubernetes/role/$environment-auth-role" \
    bound_service_account_names=auth-service-account \
    bound_service_account_namespaces="$KUBE_VAULT_NAMESPACE" \
    policies="default,policy-shared-bridge-read,policy-shared-maxmind-read,policy-infra-$environment-internals-bff-read,policy-infra-$environment-internals-auth-shared-read" \
    ttl=1h

}

# MAIN
SCRIPT_DIR="$(dirname "$0")"
DATA_DIR="$(realpath "$SCRIPT_DIR"/../data)"
CONFIG_DIR=$DATA_DIR/config

find "$DATA_DIR" -name 'policy*.hcl' -delete

for environment in production ci; do
  createRoles $environment
done

# ---

VAULT_ADDR=http://localhost:8200
VAULT_TOKEN=$(jq -r ".root_token" "$CONFIG_DIR"/cluster-keys.json)
KUBE_VAULT_NAMESPACE=vault

export VAULT_ADDR VAULT_TOKEN
find "$DATA_DIR" -name 'policy*.hcl' | xargs -tn1 -I{} /bin/bash -c 'vault policy write $(basename "$1" .hcl) "$1"' - {}
