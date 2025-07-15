#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
BATCHER_BIN="$BIN_DIR/op-batcher"

if [ -f .env ]; then
  echo "Loading environment from .env"
  set -a
  source .env
  set +a
else
  echo ".env not found"
  exit 1
fi

exec "$BATCHER_BIN" \
  --l2-eth-rpc=http://localhost:9545 \
  --rollup-rpc=http://localhost:8547 \
  --poll-interval=1s \
  --sub-safety-margin=6 \
  --num-confirmations=1 \
  --safe-abort-nonce-too-low-count=3 \
  --resubmission-timeout=30s \
  --rpc.addr=0.0.0.0 --rpc.port=8548 \
  --rpc.enable-admin \
  --max-channel-duration=$MAX_CHANNEL_DURATION \
  --l1-eth-rpc="$L1_RPC_URL" \
  --private-key="$BATCHER_PRIVATE_KEY" \
  --target-num-frames=1 \
  --max-l1-tx-size-bytes=120000 \
  --compressor=shadow \
  --compression-algo=zlib \
  --approx-compr-ratio=0.6 \
  --max-pending-tx=1 \
  --throttle-threshold=0