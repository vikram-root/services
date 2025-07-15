#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
DEPLOY_DIR="$SCRIPT_DIR/deploy-config"
DEPLOYER="$BIN_DIR/op-deployer"
INTENT_FILE="$DEPLOY_DIR/intent.toml"
JWT_FILE="$DEPLOY_DIR/jwt.txt"
GETH_BIN="$BIN_DIR/geth"
DATADIR="$SCRIPT_DIR/datadir"

mkdir -p $DATADIR
mkdir -p $DEPLOY_DIR

if [ -f .env ]; then
  echo "Loading environment from .env"
  set -a
  source .env
  set +a
else
  echo ".env not found"
  exit 1
fi

echo "Initializing deployment intent"
"$DEPLOYER" init \
  --l1-chain-id $L1_CHAIN_ID \
  --l2-chain-ids $L2_CHAIN_ID \
  --outdir "$DEPLOY_DIR" \
  --intent-type standard

dasel_patch() {
  local path="$1"
  local value="$2"
  dasel put -r toml -t string -v "$value" -f "$INTENT_FILE" "$path"
}

dasel_patch '.configType' 'custom'

dasel_patch '.superchainRoles.proxyAdminOwner'         "$ADMIN_ADDRESS"
dasel_patch '.superchainRoles.protocolVersionsOwner'   "$ADMIN_ADDRESS"
dasel_patch '.superchainRoles.guardian'                "$ADMIN_ADDRESS"

dasel_patch '.chains.[0].baseFeeVaultRecipient'        "$ADMIN_ADDRESS"
dasel_patch '.chains.[0].l1FeeVaultRecipient'          "$ADMIN_ADDRESS"
dasel_patch '.chains.[0].sequencerFeeVaultRecipient'   "$ADMIN_ADDRESS"

dasel_patch '.chains.[0].roles.l1ProxyAdminOwner'      "$ADMIN_ADDRESS"
dasel_patch '.chains.[0].roles.l2ProxyAdminOwner'      "$ADMIN_ADDRESS"
dasel_patch '.chains.[0].roles.systemConfigOwner'      "$ADMIN_ADDRESS"
dasel_patch '.chains.[0].roles.unsafeBlockSigner'      "$SEQUENCER_ADDRESS"
dasel_patch '.chains.[0].roles.batcher'                "$BATCHER_ADDRESS"
dasel_patch '.chains.[0].roles.proposer'               "$PROPOSER_ADDRESS"
dasel_patch '.chains.[0].roles.challenger'             "$CHALLENGER_ADDRESS"

echo "Applying deployment intent"
"$DEPLOYER" apply \
  --l1-rpc-url "$L1_RPC_URL" \
  --workdir "$DEPLOY_DIR" \
  --deployment-target live \
  --private-key "$ADMIN_PRIVATE_KEY"

echo "Generating deployment artifacts"
"$DEPLOYER" inspect genesis         --workdir "$DEPLOY_DIR" $L2_CHAIN_ID > "$DEPLOY_DIR/genesis.json"
"$DEPLOYER" inspect rollup          --workdir "$DEPLOY_DIR" $L2_CHAIN_ID > "$DEPLOY_DIR/rollup.json"
"$DEPLOYER" inspect l1              --workdir "$DEPLOY_DIR" $L2_CHAIN_ID > "$DEPLOY_DIR/l1-addresses.json"
"$DEPLOYER" inspect deploy-config   --workdir "$DEPLOY_DIR" $L2_CHAIN_ID > "$DEPLOY_DIR/deploy-config.json"
"$DEPLOYER" inspect l2-semvers      --workdir "$DEPLOY_DIR" $L2_CHAIN_ID > "$DEPLOY_DIR/l2-semvers.json"

openssl rand -hex 32 > "$JWT_FILE"
echo "Deployment complete. Artifacts saved in $DEPLOY_DIR"

echo "Initialising op-geth"

"$GETH_BIN" init \
  --datadir "$DATADIR" \
  --state.scheme=hash \
  "$DEPLOY_DIR/genesis.json"

echo "op-geth initialised successfully"