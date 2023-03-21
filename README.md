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

### Observations

All experiments were conducted on the `atlantic-2` testnet, which is the most recent one. We attempted to follow the docs in order to get a node synced on the `devnet-3` network, but it was not possible as no peers were ever found. The same also applies to `atlantic-2`. Following the official guides and documentation leads to a node that waits for peers during its whole lifetime.

The Discord is very active, but it is mainly for the [https://www.seinetwork.io/treasure](https://www.seinetwork.io/treasure) NFT gathering, and many people want SEI for the tasks required for the NFT claim. However, it really lacks developers and SEI managers who can answer questions related to node operations. We asked many questions on the `testnet-support` channel, and even mods were tagged, but we received no answers regarding technical questions. We wanted to get a list of peers and bootnodes to connect to in order to make the sync happen, but there was no response on the official Discord.

Fortunately, we were able to find another node operator, `brocha.in`, which provided us with the intrinsic knowledge required for running a full-node/validator-node and kindly provided peers to connect to. Huge thanks to them!

Having a node discover peers by itself is an impossible task. Therefore, we need to provide mechanisms to make the blockchain more up to date. Currently, there are two options: snap-sync (which downloads a snapshot and syncs the rest of the blockchain from that point) and state-sync (which "trusts" that the blockchain is good from a block and only syncs from that point). We had more positive results with the `snap-sync` method, which led to fast syncing times, but only eventually. More on that on the next bullet.

From our experiences, out of 10 trials made with the exact same configuration, only 3 times were we able to have the node synced (or even start the syncing process). These experiments consisted of just turning the node on/off at different times of the day and on different days. The configuration gathers the address book for a seed (provided by the `brocha.in` community). This makes it so that peers may differ every time the node is turned on.

Validator migration tests were also conducted by moving a validator created on a server to a different one. These tests were inconclusive. We tried first starting the node as a validator node (with a different private key) and swapping the keys to the intended one after the node was synced. For this swap to be effective, the node needs to be restarted. After doing so, the chain never got back in sync. This test was performed 8 times on different machines with the same result (even ones in Germany to reduce latency and bare-metals with huge 64 cores, 128 GB of RAM, and 2TB of SSD disk). We also conducted a test (this one was only performed 2 times) starting the node as a full-node and after syncing, restarted it as a validator (with migrated private keys), but we were not able to make the node sync, so we couldn't finish that test.

All in all, the network seems to be really unstable, at least the `atlantic-2` testnet, and this is due to:

- The lack of provision of trusted peers in the documentation
- The 1s block producing time doesn't help with this instability. The block production time should be increased.
- The majority of nodes are located in central Europe (Germany, Netherlands, etc.). This leads to high latency with other peers located outside of Europe.

### How to get the node in sync

In order to get the peers to be used as bootnodes we use the brocha.in RPC node:

```
STATE_SYNC_RPC=https://sei-testnet-2-rpc.brocha.in
BOOTSTRAP_PEERS=$(curl -L "$STATE_SYNC_RPC/net_info" | jq -r '[.peers[].url | capture("mconn://(?<peer>.+)").peer] | join(",")')
sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$BOOTSTRAP_PEERS\"|" ~/.sei/config/config.toml
```

Having the proper bootnodes is key for having a synced node. If this list is not provided (or has peers that are offline/behind) the node wont be able to start syncing ever. Also it is not recommended to set up the `persistent-peers` variable inside the `config.toml` file, you should rather use the `bootstrap-peers` variable instead
