#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
DEPLOY_DIR="$SCRIPT_DIR/deploy-config"
JWT_FILE="$DEPLOY_DIR/jwt.txt"
GETH_BIN="$BIN_DIR/geth"
DATADIR="$SCRIPT_DIR/datadir"

exec "$GETH_BIN" \
  --datadir "$DATADIR" \
  --http --http.addr=0.0.0.0 --http.port=9545 \
  --http.corsdomain="*" --http.vhosts="*" \
  --http.api=web3,debug,eth,txpool,net,engine,miner \
  --ws --ws.addr=0.0.0.0 --ws.port=9546 \
  --ws.origins="*" --ws.api=debug,eth,txpool,net,engine,miner \
  --syncmode=full \
  --nodiscover --maxpeers=0 \
  --networkid=42069 \
  --authrpc.addr=0.0.0.0 --authrpc.port=9551 \
  --authrpc.vhosts="*" --authrpc.jwtsecret="$JWT_FILE" \
  --rollup.disabletxpoolgossip=true \
  --state.scheme=hash