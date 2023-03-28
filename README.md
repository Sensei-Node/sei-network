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

---

## Useful data

### Latest config recommendations

```
persistent-peers = "650a118a5919c1d0eb3d9f17b14cfb2a6b1c8b9d@3.120.150.255:26656,8f61c476ae8862cf5a965f4cb61eb5e217b61927@18.197.228.134:26656,171d20a5e4a6559046cef78fbdeaea4d786c85ad@162.19.232.131:26656,622edfc381a73cb9a624815831d3cbfecab04e4a@141.94.100.234:26656,862b03573172a3366afe1cabb903ba0552689e63@198.244.228.59:11956,650a118a5919c1d0eb3d9f17b14cfb2a6b1c8b9d@3.120.150.255:26656,79389ef8775ad3310b77fcd935db30f32b5ba764@65.108.136.152:28656,4944c0fb34a76ad537f4eefa1734d6f6a2da5ed0@65.109.115.226:11956,f516643bb00dc73b88af8d259736b8cbdf682bab@65.109.32.174:33656,56a1d17ff164627a1102528014d4d165f9862985@65.109.94.250:27656,8f61c476ae8862cf5a965f4cb61eb5e217b61927@18.197.228.134:27656"
...
[statesync]
enable = true
use-p2p = false
rpc-servers = "http://statesync.atlantic-2.seinetwork.io:26657,http://statesync.atlantic-2.seinetwork.io:26657"

# The hash and height of a trusted block. Must be within the trust-period.
# you may need to get an updated one if it's too far behind

# SYNC_IP=http://statesync.atlantic-2.seinetwork.io
# STATE_SYNC_RPC="$SYNC_IP:26657"
# LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .block.header.height)
# SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 5000))
# SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .block_id.hash)

trust-height = 4050474. 
trust-hash = "7A262A6AE17B072D37D15178F172A70F02AFACB76282017BCB8374F4C0C33151"
```

### How to get validator out of jail

`seid tx slashing unjail --from admin --fees 2000usei -b block -y`

### How to modify validator commission

`seid tx staking edit-validator --commission-rate="0" --chain-id="atlantic-2" --from="admin" --fees="2000usei"`
