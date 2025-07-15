#!/bin/bash

set -euo pipefail

echo "Stopping op-batcher"
curl -s -d '{"id":0,"jsonrpc":"2.0","method":"admin_stopBatcher","params":[]}' \
  -H "Content-Type: application/json" \
  http://localhost:8548 | jq

echo "⏳ Waiting for batcher to flush and exit (check logs)"
sleep 5

echo "Stopping op-proposer"
pkill -f op-proposer || echo "op-proposer not running"

echo "Stopping op-node"
pkill -f op-node || echo "op-node not running"

echo "Stopping op-geth"
pkill -2 -f geth || echo "op-geth not running"

echo "Rollup stopped cleanly."