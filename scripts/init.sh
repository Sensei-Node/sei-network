#!/bin/bash

# copy the factory config files so that we can modify them
cp /root/sei-configs/config.toml ~/.sei/config/config.toml
cp /root/sei-configs/client.toml ~/.sei/config/client.toml
cp /root/sei-configs/priv_validator_key.json ~/.sei/config/priv_validator_key.json

# it prioritizes STATE_SYNC if enabled (over SNAP_SYNC)
if [ "$STATE_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then
        cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
        rm -rf ~/.sei/data/*
        mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json

        #STATE_SYNC_RPC=https://sei-testnet-2-rpc.brocha.in
        SYNC_IP=http://statesync.atlantic-2.seinetwork.io
        STATE_SYNC_RPC="$SYNC_IP:26657"
        LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .block.header.height)
        SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 5000))
        SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .block_id.hash)

        sed -i.bak -e "s|^enable *=.*|enable = true|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^use-p2p *=.*|use-p2p = false|" ~/.sei/config/config.toml

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

# Main configs
sed -i "s/moniker = \".*\"/moniker = \"$MONIKER\"/" ~/.sei/config/config.toml
sed -i "s/mode = \".*\"/mode = \"$MODE\"/" ~/.sei/config/config.toml
sed -i "s/chain-id = \".*\"/chain-id = \"$CHAIN_ID\"/" ~/.sei/config/client.toml

# Peer configs
#STATE_SYNC_RPC=https://sei-testnet-2-rpc.brocha.in
STATE_SYNC_RPC=http://statesync.atlantic-2.seinetwork.io:26657
# SEED_NODE=https://sei-testnet-2-seed.brocha.in
# STATE_SYNC_PEER=94b63fddfc78230f51aeb7ac34b9fb86bd042a77@sei-testnet-2.p2p.brocha.in:30588
# BOOTSTRAP_PEERS=$(curl -L "$SEED_NODE/addrbook.json" | jq -r '[.addrs[].addr | [.id,"@",.ip,":",.port] | join("")] | join(",")')
#BOOTSTRAP_PEERS=$(curl -L "$STATE_SYNC_RPC/net_info" | jq -r '[.peers[].url | capture("mconn://(?<peer>.+)").peer] | join(",")')
#BOOTSTRAP_PEERS="65c257f9275beb1b99ca169ef89743c034b15db0@3.76.192.224:26656,650a118a5919c1d0eb3d9f17b14cfb2a6b1c8b9d@3.120.150.255:26656,5710d992d9c33b01c3b23df4cbd715e9b4c7b46b@3.71.0.14:26656,272699de6f61eb4a7509ae33fa49af0d4bf13784@18.192.115.237:26656,862b03573172a3366afe1cabb903ba0552689e63@198.244.228.59:11956,1a71212a12e67dbf0d1b557e54251676f8f8af6b@65.21.200.7:7000,762cf4f35aec09857df14ac2bc78824f8f89d5db@65.109.28.219:26656"
sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" ~/.sei/config/config.toml
#sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$BOOTSTRAP_PEERS\"|" ~/.sei/config/config.toml

# More convfigs from brocha.in
#sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0001usei\"|" ~/.sei/config/app.toml
#sed -i -e "s|^pruning *=.*|pruning = \"custom\"|" ~/.sei/config/app.toml
#sed -i -e "s|^pruning-keep-recent *=.*|pruning-keep-recent = \"3000\"|" ~/.sei/config/app.toml
#sed -i -e "s|^pruning-keep-every *=.*|pruning-keep-every = \"0\"|" ~/.sei/config/app.toml
#sed -i -e "s|^pruning-interval *=.*|pruning-interval = \"10\"|" ~/.sei/config/app.toml
#sed -i -e "s|^snapshot-interval *=.*|snapshot-interval = \"1000\"|" ~/.sei/config/app.toml
#sed -i -e "s|^snapshot-keep-recent *=.*|snapshot-keep-recent = \"2\"|" ~/.sei/config/app.toml

seid start
