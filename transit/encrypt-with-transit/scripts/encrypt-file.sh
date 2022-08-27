#!/bin/bash
#
# Usage: $0 [<file to encrypt>]
#
realpath() {
  cd "$1" || echo "$1"
  pwd
  cd - >/dev/null || echo "$1"
}

# MAIN
SCRIPT_PATH="$(realpath "$(dirname "$0")")"
DATA_PATH="$(realpath "$SCRIPT_PATH/../data")"
# shellcheck disable=SC2034
VAULT_ADDR=http://localhost:8200

INPUT_FILE=${1:-$DATA_PATH/vault-logo.png}
ENCRYPTED_FILE=$INPUT_FILE.$(date "+%Y%m%d-%H%M%S").encrypted
# Encrypt the file, adding an attribute to the produced payload, in order
# to ease the output processing.
set +o pipefail
if vault write -format=json transit/encrypt/my_application plaintext="$(base64 < <(cat "$INPUT_FILE"))" | jq '. + {datatype:"png"}' >"$ENCRYPTED_FILE"; then
  echo "File $INPUT_FILE as been encrypted: $ENCRYPTED_FILE"
else
  echo "Failed to encrypt $INPUT_FILE"
  rm -f "$ENCRYPTED_FILE"
  exit 1
fi
