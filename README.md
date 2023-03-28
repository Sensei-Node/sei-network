# [seinetwork](https://www.seinetwork.io/)

## General 

Sei is the first sector-specific Layer 1 blockchain, specialized for trading and descentralized exchanges. 

This repository contains a Dockerfile which installs, configures and runs the node looking for the latest snapshot or using the StateSync function for faster syncronization with the network. 


## Instructions

```
git clone https://github.com/Sensei-Node/sei-network
cd sei-network
``` 

### Setup .env file

Make a copy of the `.env-default` to `.env` and modify it according to your node neccesities. Note: STATE_SYNC and SNAP_SYNC are only available for atlantic-2 testnet.

```
# node moniker for identification
MONIKER=sei-node-1

# setup the chain id (current testnet is atlantic-2)
CHAIN_ID=sei-devnet-3|atlantic-2 # choose chain id

# common modes are full (for full node) and validator (for validator node)
MODE=full|validator # choose full, validator, etc.

# for downloading the genesis, currently only setup for atlantic-2
GET_GENESIS= # leave empty if dont want to get genesis file, otherwise put anything

# you can only use STATE_SYNC or SNAP_SYNC, it prioritizes STATE_SYNC
# currently only set up for atlantic-2
STATE_SYNC= # leave empty if dont want to use state sync (for fast sync), otherwise put anything
SNAP_SYNC= # leave empty if dont want to sync from snapshot, otherwise put anything
```

### Run the node

```
docker-compose up -d
``` 

### How to get the node in sync

Testnets have shown inestability and it is very hard to find good peers to connect to, in order to get the peers to be used as bootnodes you can use the brocha.in RPC node:

```
STATE_SYNC_RPC=https://sei-testnet-2-rpc.brocha.in
BOOTSTRAP_PEERS=$(curl -L "$STATE_SYNC_RPC/net_info" | jq -r '[.peers[].url | capture("mconn://(?<peer>.+)").peer] | join(",")')
sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$BOOTSTRAP_PEERS\"|" ~/.sei/config/config.toml
```

Having the proper bootnodes is key for having a synced node. If this list is not provided (or has peers that are offline/behind) the node wont be able to start syncing ever. Also it is not recommended to set up the `persistent-peers` variable inside the `config.toml` file, you should rather use the `bootstrap-peers` variable instead
