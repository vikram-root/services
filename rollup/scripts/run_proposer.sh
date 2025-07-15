#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
DEPLOY_DIR="$SCRIPT_DIR/deploy-config"
PROPOSER_BIN="$BIN_DIR/op-proposer"
DEPLOYER_BIN="$BIN_DIR/op-deployer"

if [ -f .env ]; then
  echo "Loading environment from .env"
  set -a
  source .env
  set +a
else
  echo ".env not found"
  exit 1
fi

GAME_FACTORY_ADDRESS=$(
"$DEPLOYER_BIN" inspect l1 --workdir "$DEPLOY_DIR" "$L2_CHAIN_ID" \
| jq -r '.opChainDeployment.disputeGameFactoryProxyAddress'
)

exec "$PROPOSER_BIN" \
  --poll-interval=10s \
  --rpc.port=9560 \
  --rollup-rpc=http://localhost:8547 \
  --game-factory-address="$GAME_FACTORY_ADDRESS" \
  --private-key="$PROPOSER_PRIVATE_KEY" \
  --l1-eth-rpc="$L1_RPC_URL" \
  --allow-non-finalized \
  --num-confirmations=1 \
  --proposal-interval=10s \
  --wait-node-sync=true \
  --log.level=debug