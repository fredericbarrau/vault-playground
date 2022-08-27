#!/bin/bash
#
# Usage: $0 [<file to decrypt>]
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

INPUT_FILE=${1:-$DATA_PATH/vault-logo.png.encrypted}
INPUT_FILE_BASENAME=$(basename "$INPUT_FILE" .encrypted)
DATA_EXT="$(jq -r ".datatype" <"$INPUT_FILE")"
DECRYPTED_FILE=$DATA_PATH/$INPUT_FILE_BASENAME.decrypted.$DATA_EXT

CIPHERTEXT="$(jq -r ".data.ciphertext" <"$INPUT_FILE")"
if [[ ! -s $INPUT_FILE ]]; then
  echo "Input file not found"
  exit 2
fi
set -o pipefail
if vault write -field=plaintext transit/decrypt/my_application ciphertext="$CIPHERTEXT" | base64 --decode >"$DECRYPTED_FILE"; then
  echo "File $INPUT_FILE as been decrypted: $DECRYPTED_FILE"
else
  rm -f "$DECRYPTED_FILE"
  echo "Failed to decrypt $INPUT_FILE"
  exit 1
fi
