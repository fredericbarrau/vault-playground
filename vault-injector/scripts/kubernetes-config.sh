#!/bin/bash
#
#
realpath() {
  cd "$1" || echo "$1"
  pwd
  cd - >/dev/null || echo "$1"
}

# MAIN
SCRIPT_DIR="$(dirname "$0")"
CONFIG_DIR="$(realpath "$SCRIPT_DIR"/../kubernetes-configuration)"
RELEASE_VERSION=0.21.0 # Vault 1.11.2
set -e

if ! kubectl get namespace vault >/dev/null 2>&1; then
  kubectl create namespace vault
fi

# Create the ServiceAccount
kubectl apply -f "$CONFIG_DIR/ServiceAccount.yaml"

# RBAC : binding the TokenReview API auth to the ServiceAccount
kubectl apply -f "$CONFIG_DIR/rbac-ClusterRoleBinding.yaml"

# ADD Vault Injector using the helm chart
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

if ! helm status vault --namespace vault; then
  helm install vault hashicorp/vault \
    --namespace vault --version "$RELEASE_VERSION" \
    --values "$CONFIG_DIR"/helm-vault-injector.yaml
else
  helm upgrade vault hashicorp/vault \
    --namespace vault --version "$RELEASE_VERSION" \
    --values "$CONFIG_DIR"/helm-vault-injector.yaml

fi
