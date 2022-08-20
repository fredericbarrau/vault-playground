#!/usr/bin/env bash
#
# Name:         start-vault-server.sh
# Description:  Start a local vault dev server
#

cleanup() {
  # kill all processes whose parent is this process
  pkill -P $$
}

realpath() {
  cd "$1" || echo "$1"
  pwd
  cd - >/dev/null || echo "$1"
}

trap cleanup EXIT TERM

# MAIN
SCRIPT_PATH="$(realpath "${0%/*}")"
LOG_PATH="$(realpath "$SCRIPT_PATH/../log")"
VAULT_LOG="$LOG_PATH/vault.log"
TF_DEV_PATH="$(realpath "$SCRIPT_PATH/../vault-configuration/environments/development")"

set -o pipefail
(
  vault server -dev >"$VAULT_LOG" 2>&1
) &
sleep 5
ROOT_TOKEN=$(sed -nE "s/Root Token: (.*)$/\1/p" "$VAULT_LOG")

(
  cat <<EOF
provider "vault" {
  token = "$ROOT_TOKEN"
}
EOF
) >"$TF_DEV_PATH/override.tf"

echo "Development Vault server started "
echo "Terraform authentication file has been set for vault dev server"
echo "Press [ENTER] to stop the vault server..."
read -r response
exit 0
