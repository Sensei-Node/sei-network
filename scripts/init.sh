#!/bin/bash

# copy the factory config files so that we can modify them
cp /sei-config/config.toml ~/.sei/config/config.toml
cp /sei-config/client.toml ~/.sei/config/client.toml

# it prioritizes STATE_SYNC if enabled (over SNAP_SYNC)
if [ "$STATE_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then

        cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
        rm -rf ~/.sei/data/*
        mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json
        
        STATE_SYNC_RPC=https://sei-testnet-2-rpc.brocha.in:443
        STATE_SYNC_PEER=94b63fddfc78230f51aeb7ac34b9fb86bd042a77@sei-testnet-2.p2p.brocha.in:30588
        LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
        SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
        SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

        sed -i.bak -e "s|^enable *=.*|enable = true|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$STATE_SYNC_PEER\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^use-p2p *=.*|use-p2p = true|" ~/.sei/config/config.toml

    fi
elif [ "$SNAP_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then
        SNAPSHOT_FILE=$(curl -Ls https://snapshots.brocha.in/sei-testnet-2/atlantic-2.json | jq -r .goleveldb.file)
        curl -L https://snapshots.brocha.in/sei-testnet-2/$SNAPSHOT_FILE | lz4 -dc - | tar -xf - -C ~/.sei
    fi
fi

if [ "$GET_GENESIS" != "" ]; then
    curl https://raw.githubusercontent.com/sei-protocol/testnet/master/$CHAIN_ID/genesis.json > ~/.sei/config/genesis.json
fi

# NEED TO TEST THESE COMMANDS
sed -i "s/moniker = \".*\"/moniker = \"$MONIKER\"/" ~/.sei/config/config.toml
sed -i "s/mode = \".*\"/mode = \"$MODE\"/" ~/.sei/config/config.toml
sed -i "s/chain-id = \".*\"/chain-id = \"$CHAIN_ID\"/" ~/.sei/config/client.toml

seid start
