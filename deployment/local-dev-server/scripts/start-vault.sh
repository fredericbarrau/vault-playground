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

startVault() {
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
  ) >"$OVERRIDE_FILE"

  echo "Development Vault server started "
  echo "Terraform authentication file has been created: $OVERRIDE_FILE"

}

trap cleanup EXIT TERM

# MAIN
SCRIPT_PATH="$(realpath "$(dirname "$0")")"
DATA_PATH="$(realpath "$SCRIPT_PATH/../data")"
LOG_PATH="$(realpath "$DATA_PATH/log")"
VAULT_LOG="$LOG_PATH/vault.log"
OVERRIDE_FILE=$DATA_PATH/override.tf

mkdir -p "$LOG_PATH"

startVault

echo "Press [ENTER] to stop the vault server..."
read -r
exit 0
