#!/bin/bash

set -euo pipefail

PK="${1:?private key missing}"
TO="${2:?receiver address missing}"
AMOUNT="${3:-1}"
RPC="${4:-http://localhost:8545}"

cast send \
  --private-key "$PK" \
  --value "${AMOUNT}ether" \
  --rpc-url "$RPC" \
  "$TO"

echo "✅ Sent $AMOUNT ETH to $TO on $RPC"