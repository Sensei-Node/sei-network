# [seinetwork](https://www.seinetwork.io/)
This is the protocol of sei network


## General 

Sei is the first sector-specific Layer 1 blockchain, specialized for trading to give exchanges an unfair advantage

Decentralized exchanges (DEXes) are the killer app of crypto. They are everywhere, spanning much further than just AMMs and orderbooks. DEXes are just as prevalent across NFTs and gaming as well. One of the primary use cases of NFTs today is trading them on an NFT marketplace, another example of an exchange. Most games in crypto have built-in exchanges for users to trade the in-game NFTs and tokens. DEXes command the largest network effect, major ecosystems get built around them.
Ironically, decentralized exchanges are also the most underserved application in crypto. They demand a unique level of requirements for reliability, scalability, and speed that no other apps need. If a large exchange goes down for a few moments it’s catastrophic, but the same downtime is far more tolerable for most other application types. Historically, DEXes have succeeded in spite of the drawbacks of existing Layer 1 blockchains.
Sei is the first sector-specific Layer 1 blockchain, specialized for trading. Every aspect of the blockchain has been optimized to help exchanges run better and offer the best UX for their end users. 
1. Native order matching engine - drives scalability of orderbook DEXs built on Sei
2. Breaking Tendermint - Sei is the fastest chain to finality at ~600ms
3. Twin-turbo consensus - improves latency and throughput
4. Frontrunning protection - combats malicious frontrunning that is rampant in other ecosystems
5. Market-based parallelization - specialized parallelization for DeFi
The combination of these optimizations make it possible for new types of financial products to emerge—everything ranging from fully on-chain orderbook DEXs to live sports betting.

## Run the node

```
git clone 
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






