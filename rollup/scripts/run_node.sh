#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
DEPLOY_DIR="$SCRIPT_DIR/deploy-config"
JWT_FILE="$DEPLOY_DIR/jwt.txt"
NODE_BIN="$BIN_DIR/op-node"
ROLLUP_JSON="$DEPLOY_DIR/rollup.json"

if [ -f .env ]; then
  echo "Loading environment from .env"
  set -a
  source .env
  set +a
else
  echo ".env not found"
  exit 1
fi

exec "$NODE_BIN" \
  --l2=http://localhost:9551 \
  --l2.jwt-secret="$JWT_FILE" \
  --sequencer.enabled \
  --sequencer.l1-confs=5 \
  --verifier.l1-confs=4 \
  --rollup.config="$ROLLUP_JSON" \
  --rpc.addr=0.0.0.0 --rpc.port=8547 \
  --rpc.enable-admin \
  --p2p.disable \
  --p2p.sequencer.key="$SEQUENCER_PRIVATE_KEY" \
  --l1="$L1_RPC_URL" --l1.rpckind=$L1_RPC_KIND \
  --l1.beacon.ignore=true