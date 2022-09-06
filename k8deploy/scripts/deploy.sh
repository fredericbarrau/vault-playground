#!/usr/bin/env bash
#
# Implementing: https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube-raft
#
set -e

realpath() {
  cd "$1" || echo "$1"
  pwd
  cd - >/dev/null || echo "$1"
}

SCRIPT_DIR="$(dirname "$0")"
DATA_DIR="$(realpath "$SCRIPT_DIR"/../data)"
CONFIG_DIR=$DATA_DIR/config
TERRAFORM_DIR="$(realpath "$SCRIPT_DIR"/../vault-configuration/environments/development/)"
VAULT_VERSION=0.21.0 # Vault 1.11.2

if ! kubectl get namespace vault >/dev/null 2>&1; then
  kubectl create namespace vault
fi

mkdir -p "$CONFIG_DIR"

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

if ! helm status vault --namespace vault; then
  cat >"$CONFIG_DIR"/helm-vault-raft-values.yml <<EOF
server:
  affinity: ""
  ha:
    enabled: true
    raft: 
      enabled: true
EOF

  helm install vault hashicorp/vault \
    --namespace vault --version "$VAULT_VERSION" \
    --values "$CONFIG_DIR"/helm-vault-raft-values.yml
fi

kubectl exec vault-0 --namespace vault -- vault operator init \
  -key-shares=1 \
  -key-threshold=1 \
  -format=json >"$CONFIG_DIR"/cluster-keys.json

VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" "$CONFIG_DIR"/cluster-keys.json)

kubectl exec --namespace vault vault-0 -- vault operator unseal "$VAULT_UNSEAL_KEY"

kubectl exec --namespace vault -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec --namespace vault -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200

kubectl exec --namespace vault -ti vault-1 -- vault operator unseal "$VAULT_UNSEAL_KEY"
kubectl exec --namespace vault -ti vault-2 -- vault operator unseal "$VAULT_UNSEAL_KEY"

#echo "ROOT TOKEN:"
ROOT_TOKEN=$(jq -r ".root_token" "$CONFIG_DIR"/cluster-keys.json)

cat <<EOF >"$TERRAFORM_DIR"/override.tf
  provider "vault" {
    token = "$ROOT_TOKEN"
  }
EOF
# ---
# Setup Terraform
#

TF_VAR_kubernetes_host=$(kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh -c 'echo https://$KUBERNETES_PORT_443_TCP_ADDR:443')
