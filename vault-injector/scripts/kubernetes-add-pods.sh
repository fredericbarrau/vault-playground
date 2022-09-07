#!/usr/bin/env bash
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
set -e
