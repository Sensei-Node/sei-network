#!/bin/bash

# it prioritizes STATE_SYNC if enabled (over SNAP_SYNC)
if [ "$STATE_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then
        cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
        rm -rf ~/.sei/data/*
        mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json

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
STATE_SYNC_RPC=http://statesync.atlantic-2.seinetwork.io:26657
PERSISTENT_PEERS="650a118a5919c1d0eb3d9f17b14cfb2a6b1c8b9d@3.120.150.255:26656,8f61c476ae8862cf5a965f4cb61eb5e217b61927@18.197.228.134:26656,171d20a5e4a6559046cef78fbdeaea4d786c85ad@162.19.232.131:26656,622edfc381a73cb9a624815831d3cbfecab04e4a@141.94.100.234:26656,862b03573172a3366afe1cabb903ba0552689e63@198.244.228.59:11956,650a118a5919c1d0eb3d9f17b14cfb2a6b1c8b9d@3.120.150.255:26656,79389ef8775ad3310b77fcd935db30f32b5ba764@65.108.136.152:28656,4944c0fb34a76ad537f4eefa1734d6f6a2da5ed0@65.109.115.226:11956,f516643bb00dc73b88af8d259736b8cbdf682bab@65.109.32.174:33656,56a1d17ff164627a1102528014d4d165f9862985@65.109.94.250:27656,8f61c476ae8862cf5a965f4cb61eb5e217b61927@18.197.228.134:27656"
sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" ~/.sei/config/config.toml
sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" ~/.sei/config/config.toml

seid start
