#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(pwd)"
WORKDIR="$SCRIPT_DIR/app"
OPTIMISM_DIR="$WORKDIR/optimism"
OP_GETH_DIR="$WORKDIR/op-geth"
BIN_OUT="$SCRIPT_DIR/bin"

mkdir -p $WORKDIR
mkdir -p $BIN_OUT

git config --global --add safe.directory '*'

echo "Cloning Optimism repo"
git clone https://github.com/ethereum-optimism/optimism.git "$OPTIMISM_DIR"

cd "$OPTIMISM_DIR"
echo "Checking out v1.13.2 and submodules"
git fetch --tags --all
git checkout v1.13.2
git submodule update --init --recursive

echo "Building op-node, op-batcher, op-proposer"
make op-node op-batcher op-proposer

echo "Building op-deployer"
cd op-deployer
just build


echo "Cloning op-geth repo"
git clone https://github.com/ethereum-optimism/op-geth.git "$OP_GETH_DIR"

cd "$OP_GETH_DIR"
echo "Checking out v1.101503.4-rc.1"
git fetch --tags --all
git checkout v1.101503.4-rc.1

echo "Building geth"
make geth

echo "Build complete."

cp "$OPTIMISM_DIR/op-node/bin/op-node"         "$BIN_OUT/"
cp "$OPTIMISM_DIR/op-batcher/bin/op-batcher"   "$BIN_OUT/"
cp "$OPTIMISM_DIR/op-proposer/bin/op-proposer" "$BIN_OUT/"
cp "$OPTIMISM_DIR/op-deployer/bin/op-deployer" "$BIN_OUT/"
cp "$OP_GETH_DIR/build/bin/geth"               "$BIN_OUT/"

echo "Copied binaries to $BIN_OUT:"
ls -1 "$BIN_OUT"

rm -rf "$WORKDIR"
exec "$@"