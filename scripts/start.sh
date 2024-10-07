#!/bin/bash

if [ -z "$CHAIN_ID" ]; then
  echo "CHAIN_ID is empty, exiting..."
  exit 1
fi

HOME_PATH="/root/.sei"
CONFIG_PATH="$HOME_PATH/config/config.toml"
APP_PATH=$HOME_PATH/config/app.toml
CLIENT_PATH=$HOME_PATH/config/client.toml

set_peering() {
  echo "Setting persistent peers..."
  OUR_PEERS=$INCLUDE_PEERS
  SELF=$(cat $HOME_PATH/config/node_key.json |jq -r .id)
  echo $(echo $OUR_PEERS |grep -v "$SELF") > OUR_PEERS
  OUR_PEERS="$(paste -s -d ',' OUR_PEERS)"
  curl "$PRIMARY_RPC"/net_info |jq -r '.peers[] | .url' |sed -e 's#mconn://##' |grep -v "$SELF" |grep -v "localhost" |grep -v "127.0.0.1" |grep -v "0.0.0.0" > PEERS
  PRUNED_PEERS="$(paste -s -d ',' PEERS)"
  PERSISTENT_PEERS="$PRUNED_PEERS,$OUR_PEERS"
  sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" $HOME_PATH/config/config.toml
  sed -i.bak -e "s|^pex *=.*|pex = true|" $HOME_PATH/config/config.toml
}

# Initialize cosmovisor and copy binaries
if [ ! -f "$HOME_PATH/cosmovisor/config.toml" ]; then
  cosmovisor init /root/binaries/${REL_TAG}/seid
  # Needs a data folder in order to execute run commands
  mkdir -p $HOME_PATH/data
fi

# Cleanup the node
if [ ! -z "$PRUNE_DATA" ]; then
  echo "Backing up val state..."
  cp $HOME_PATH/data/priv_validator_state.json $HOME_PATH/priv_validator_state.json.backup
  echo "Pruning data, wasm folder..."
  rm -rf $HOME_PATH/data/*
  rm -rf $HOME_PATH/wasm
  echo "Restoring from backup..."
  mv $HOME_PATH/priv_validator_state.json.backup $HOME_PATH/data/priv_validator_state.json
fi

# Set up the RPC
if [ "$CHAIN_ID" = "atlantic-2" ]; then
  PRIMARY_RPC="https://sei-testnet-rpc.polkachu.com:443"
  PRIMARY_SNAP="https://snapshots.polkachu.com/testnet-genesis"
elif [ "$CHAIN_ID" = "pacific-1" ]; then
  PRIMARY_RPC="https://sei-rpc.polkachu.com:443"
  PRIMARY_SNAP="https://snapshots.polkachu.com/genesis"
fi

# Initializes the node, downloads genesis and syncs from state/snapshot
if [ ! -f "$HOME_PATH/config/genesis.json" ]; then
  # Initialize the node
  cosmovisor run init $MONIKER --chain-id $CHAIN_ID --home $HOME_PATH
  # Get the genesis file 
  wget -O $HOME_PATH/config/genesis.json "$PRIMARY_SNAP/sei/genesis.json" --inet4-only
  # Set primary rpcs
  sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$PRIMARY_RPC,$PRIMARY_RPC\"|" $HOME_PATH/config/config.toml
  if [ ! -z "$USE_STATE_SYNC" ]; then
    # For atlantic-2 testnet we also get the addrbook
    if [ "$CHAIN_ID" = "atlantic-2" ]; then
      WASM_URL="https://snapshots.polkachu.com/testnet-wasm/sei/sei_wasmonly.tar.lz4"
      if [ -z "$HAS_PRIVATE_VALIDATOR" ]; then
        # Addrbook get
        wget -O addrbook.json https://snapshots.polkachu.com/testnet-addrbook/sei/addrbook.json --inet4-only
        mv addrbook.json $HOME_PATH/config
      fi
    elif [ "$CHAIN_ID" = "pacific-1" ]; then
      WASM_URL="https://snapshots.kjnodes.com/sei/wasm_latest.tar.lz4"
    fi
    # Remove wasm folder if it exists
    rm -rf $HOME_PATH/wasm
    # Get our wasm folder
    wget -O sei_wasmonly.tar.lz4 $WASM_URL --inet4-only
    # Extract the wasm folder into the right place
    lz4 -c -d sei_wasmonly.tar.lz4  | tar -x -C $HOME_PATH
    # Clean up
    rm -rf sei_wasmonly.tar.lz4

    # Example: set trust height and hash to be the block height 20,000 earlier
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
    sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME_PATH/config/config.toml
    sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" $HOME_PATH/config/config.toml
    sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" $HOME_PATH/config/config.toml
    sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" $HOME_PATH/config/config.toml
    # Set peering
    set_peering
  elif [ ! -z "$USE_SNAPSHOTS" ]; then
    if [ "$CHAIN_ID" = "pacific-1" ]; then
      # Use snapshot sync for mainnet
      echo "Downloading latest snapshot..."
      curl -L https://snapshots.kjnodes.com/sei/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME_PATH
    fi
  fi
  # For mainnet we set min gas price and seed nodes
  if [ "$CHAIN_ID" = "pacific-1" ]; then
    # Set min gas price
    sed -i.bak -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.02usei\"|" $HOME_PATH/config/app.toml
    # Using a seed node to bootstrap is considered the best practice
    if [ -z "$HAS_PRIVATE_VALIDATOR" ]; then
      if grep -q '^seeds =' "$HOME_PATH/config/config.toml"; then
        sed -i.bak -e "s|^seeds *=.*|seeds = \"400f3d9e30b69e78a7fb891f60d76fa3c73f0ecc@sei.rpc.kjnodes.com:16859\"|" $HOME_PATH/config/config.toml
      else
        echo 'seeds = "400f3d9e30b69e78a7fb891f60d76fa3c73f0ecc@sei.rpc.kjnodes.com:16859"' >> "$HOME_PATH/config/config.toml"
      fi
    fi
  fi
fi

# Set peering
if [ ! -z "$RESET_PEERS" ]; then
  set_peering
fi

# Do not broadcast this peer id
if [ ! -z "$PRIVATE_PEER" ]; then
  echo "Excluding defined private peer..."
  sed -i.bak -e "s|^private-peer-ids *=.*|private-peer-ids = \"$PRIVATE_PEER\"|" $HOME_PATH/config/config.toml
fi

# Use SeiDB (new db for seiv2)
if [ ! -z "$USE_SEI_DB" ]; then
  echo "Setting up SeiDB..."
  sed -i.bak -e "s|^sc-enable *=.*|sc-enable = true|" $HOME_PATH/config/app.toml
  sed -i.bak -e "s|^sc-snapshot-writer-limit *=.*|sc-snapshot-writer-limit = 1|" $HOME_PATH/config/app.toml
  if grep -q '^sc-cache-size =' "$HOME_PATH/config/app.toml"; then
    sed -i.bak -e "s|^sc-cache-size *=.*|sc-cache-size = 100000|" $HOME_PATH/config/app.toml
  else
    sed -i '/^\[state-commit\]/a sc-cache-size = 100000' $HOME_PATH/config/app.toml
  fi
  if [ "$MODE" != "validator" ]; then
    sed -i.bak -e "s|^ss-enable *=.*|ss-enable = true|" $HOME_PATH/config/app.toml
  else
    sed -i.bak -e "s|^ss-enable *=.*|ss-enable = false|" $HOME_PATH/config/app.toml
  fi
fi

# Do not advertise peers, for connecting from a validator to a sentry only
if [ ! -z "$HAS_PRIVATE_VALIDATOR" ]; then
  echo "Setting pex to false..."
  sed -i.bak -e "s|^pex *=.*|pex = false|" $HOME_PATH/config/config.toml
  echo "Setting private sentry persistent peer..."
  OUR_PEERS=$INCLUDE_PEERS
  SELF=$(cat $HOME_PATH/config/node_key.json |jq -r .id)
  echo $(echo $OUR_PEERS |grep -v "$SELF") > OUR_PEERS
  OUR_PEERS="$(paste -s -d ',' OUR_PEERS)"
  sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$OUR_PEERS\"|" $HOME_PATH/config/config.toml
fi

# General settings
sed -i -e "s/moniker = \".*\"/moniker = \"$MONIKER\"/" $HOME_PATH/config/config.toml
sed -i -e "s/mode = \".*\"/mode = \"$MODE\"/" $HOME_PATH/config/config.toml
sed -i -e "s/chain-id = \".*\"/chain-id = \"$CHAIN_ID\"/" $HOME_PATH/config/client.toml
sed -i -e "s|^max-connections *=.*|max-connections = 400|" $HOME_PATH/config/config.toml
sed -i 's/127\.0\.0\.1/0.0.0.0/g' $HOME_PATH/config/config.toml
# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME_PATH/config/app.toml
# Other settings
sed -i -e "s/ttl-duration = \".*\"/ttl-duration = \"15s\"/" $HOME_PATH/config/config.toml
sed -i -e "s|^ttl-num-blocks *=.*|ttl-num-blocks = 30|" $HOME_PATH/config/config.toml
if [ "$MODE" = "validator" ]; then
  sed -i -e "s|^indexer *=.*|indexer = [\"null\"]|" $HOME_PATH/config/config.toml
fi

cosmovisor run start