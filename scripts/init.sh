#!/bin/bash

#SNAPSHOT_FILE=$(curl -Ls https://snapshots.brocha.in/sei-testnet-2/atlantic-2.json | jq -r .goleveldb.file)
#curl -L https://snapshots.brocha.in/sei-testnet-2/$SNAPSHOT_FILE | lz4 -dc - | tar -xf - -C ~/.sei
#curl https://raw.githubusercontent.com/sei-protocol/testnet/master/atlantic-2/genesis.json > ~/.sei/config/genesis.json

cp /sei-config/config.toml ~/.sei/config/config.toml
cp /sei-config/client.toml ~/.sei/config/client.toml

#sed -i.bak -e "s|^moniker *=.*|moniker = $MONIKER|" ~/.sei/config/config.toml
#sed -i.bak -e "s|^mode *=.*|mode = $MODE|" ~/.sei/config/config.toml
#sed -i.bak -e "s|^chain-id *=.*|chain-id = $CHAIN_ID|" ~/.sei/config/client.toml

seid start
