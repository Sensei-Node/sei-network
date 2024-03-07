#!/bin/bash

if [ "$INIT_NODE" != "" ]; then
  # Set node configuration
  seid config chain-id $CHAIN_ID
  seid config keyring-backend file

  # Initialize the node
  seid init $MONIKER --chain-id $CHAIN_ID

  # Download genesis
  curl -Ls https://snapshots.kjnodes.com/sei/genesis.json > $HOME/.sei/config/genesis.json
fi

# if [ "$SET_CUSTOM_PORTS" != "" ]; then
#   # Set custom ports
#   seid config node tcp://0.0.0.0:16857
#   sed -i -e "s%^proxy_app = \"tcp://0.0.0.0:26658\"%proxy_app = \"tcp://0.0.0.0:16858\"%; s%^laddr = \"tcp://0.0.0.0:26657\"%laddr = \"tcp://0.0.0.0:16857\"%; s%^pprof_laddr = \"0.0.0.0:6060\"%pprof_laddr = \"0.0.0.0:16860\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16856\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":16866\"%" $HOME/.sei/config/config.toml
#   sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:16817\"%; s%^address = \":8080\"%address = \":16880\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:16890\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:16891\"%; s%:8545%:16845%; s%:8546%:16846%; s%:6065%:16865%" $HOME/.sei/config/app.toml
# fi

# Add seeds
sed -i -e "s|^seeds *=.*|seeds = \"400f3d9e30b69e78a7fb891f60d76fa3c73f0ecc@sei.rpc.kjnodes.com:16859\"|" $HOME/.sei/config/config.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.02usei\"|" $HOME/.sei/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.sei/config/app.toml

if [ "$PRUNE_DATA" != "" ]; then
  echo "Backing up validator_state..."
  cp $HOME/.sei/data/priv_validator_state.json $HOME/.sei/priv_validator_state.json.backup
  echo "Pruning data folder..."
  rm -rf $HOME/.sei/data/*
  mv $HOME/.sei/priv_validator_state.json.backup $HOME/.sei/data/priv_validator_state.json
fi

if [ "$DOWNLOAD_SNAPSHOT" != "" ]; then
  # Download latest chain snapshot
  echo "Downloading latest snapshot..."
  curl -L https://snapshots.kjnodes.com/sei/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.sei
fi

seid start