#!/bin/bash

curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-devnet-3/genesis.json > ~/.sei/config/genesis.json

cp /sei-config/config.toml ~/.sei/config/config.toml
cp /sei-config/client.toml ~/.sei/config/client.toml

#sed -i.bak -e "s|^moniker *=.*|moniker = $MONIKER|" ~/.sei/config/config.toml
#sed -i.bak -e "s|^mode *=.*|mode = $MODE|" ~/.sei/config/config.toml
#sed -i.bak -e "s|^chain-id *=.*|chain-id = $CHAIN_ID|" ~/.sei/config/client.toml

seid start
seid status
