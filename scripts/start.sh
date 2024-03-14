#!/bin/bash

if [ -z "$CHAIN_ID" ]; then
  echo "CHAIN_ID is empty, exiting..."
  exit 1
fi

# Set up the RPC
if [ "$CHAIN_ID" = "atlantic-2" ]; then
  PRIMARY_RPC="https://sei-testnet-rpc.polkachu.com:443"
  PRIMARY_SNAP="https://snapshots.polkachu.com/testnet-genesis"
elif [ "$CHAIN_ID" = "pacific-1" ]; then
  PRIMARY_RPC="https://sei-rpc.polkachu.com:443"
  PRIMARY_SNAP="https://snapshots.polkachu.com/genesis"
fi

if [ "$INIT_NODE" != "" ]; then
  # Initialize the node
  seid init $MONIKER --chain-id $CHAIN_ID
  # Get the genesis file 
  wget -O $HOME/.sei/config/genesis.json "$PRIMARY_SNAP/sei/genesis.json" --inet4-only
  # Set primary rpcs
  sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$PRIMARY_RPC,$PRIMARY_RPC\"|" $HOME/.sei/config/config.toml
fi

# Cleanup the node
if [ "$PRUNE_DATA" != "" ]; then
  echo "Backing up val state..."
  cp $HOME/.sei/data/priv_validator_state.json $HOME/.sei/priv_validator_state.json.backup
  echo "Pruning data folder..."
  rm -rf $HOME/.sei/data/*
  echo "Restoring from backup..."
  mv $HOME/.sei/priv_validator_state.json.backup $HOME/.sei/data/priv_validator_state.json
fi

# Use state sync for testnet for fast syncing, and download wasm with addrbook
if [ "$CHAIN_ID" = "atlantic-2" ]; then
  # Remove the empty wasm folder if you have an empty one
  rm -rf $HOME/.sei/wasm
  # Get our wasm folder
  wget -O sei_wasmonly.tar.lz4 https://snapshots.polkachu.com/testnet-wasm/sei/sei_wasmonly.tar.lz4 --inet4-only
  # Extract the wasm folder into the right place
  lz4 -c -d sei_wasmonly.tar.lz4  | tar -x -C $HOME/.sei
  # Clean up
  rm -rf sei_wasmonly.tar.lz4

  # Addrbook get
  wget -O addrbook.json https://snapshots.polkachu.com/testnet-addrbook/sei/addrbook.json --inet4-only
  mv addrbook.json $HOME/.sei/config

  # Example: set trust height and hash to be the block height 10,000 earlier
  TRUST_HEIGHT_DELTA=20000
  LATEST_HEIGHT=$(curl -s "$PRIMARY_RPC"/block | jq -r ".block.header.height")
  if [ "$LATEST_HEIGHT" -gt "$TRUST_HEIGHT_DELTA" ]; then
    SYNC_BLOCK_HEIGHT=$((LATEST_HEIGHT - TRUST_HEIGHT_DELTA))
  else
    SYNC_BLOCK_HEIGHT=$LATEST_HEIGHT
  fi
  # Get trust hash
  SYNC_BLOCK_HASH=$(curl -s "$PRIMARY_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r ".block_id.hash")
  # Override configs
  sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/.sei/config/config.toml
  sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" $HOME/.sei/config/config.toml
  sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" $HOME/.sei/config/config.toml
  sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" $HOME/.sei/config/config.toml
elif [ "$CHAIN_ID" = "pacific-1" ]; then
  # Use snapshot sync for mainnet
  echo "Downloading latest snapshot..."
  sed -i.bak -e "s|^seeds *=.*|seeds = \"400f3d9e30b69e78a7fb891f60d76fa3c73f0ecc@sei.rpc.kjnodes.com:16859\"|" $HOME/.sei/config/config.toml
  sed -i.bak -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.02usei\"|" $HOME/.sei/config/app.toml
  curl -L https://snapshots.kjnodes.com/sei/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.sei
fi

# Set peering
OUR_PEERS=$INCLUDE_PEERS
SELF=$(cat $HOME/.sei/config/node_key.json |jq -r .id)
$(echo $OUR_PEERS |grep -v "$SELF") > OUR_PEERS
OUR_PEERS="$(paste -s -d ',' OUR_PEERS)"
curl "$PRIMARY_RPC"/net_info |jq -r '.peers[] | .url' |sed -e 's#mconn://##' |grep -v "$SELF" |grep -v "localhost" |grep -v "127.0.0.1" |grep -v "0.0.0.0" > PEERS
PRUNED_PEERS="$(paste -s -d ',' PEERS)"
PERSISTENT_PEERS="$PRUNED_PEERS,$OUR_PEERS"
# PERSISTENT_PEERS=$PRUNED_PEERS
echo $PERSISTENT_PEERS
sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" $HOME/.sei/config/config.toml

# General settings
sed -i -e "s/moniker = \".*\"/moniker = \"$MONIKER\"/" $HOME/.sei/config/config.toml
sed -i -e "s/mode = \".*\"/mode = \"$MODE\"/" $HOME/.sei/config/config.toml
sed -i -e "s/chain-id = \".*\"/chain-id = \"$CHAIN_ID\"/" $HOME/.sei/config/client.toml
sed -i -e "s|^max-connections *=.*|max-connections = 200|" $HOME/.sei/config/config.toml
# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.sei/config/app.toml

seid start