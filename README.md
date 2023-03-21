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

All the experiencies were conducted in `atlantic-2` testnet (which is the most recent one). We tried following the docs in order to get a node synced on the `devnet-3` network but it was not possible, no peers were ever found. Same applies for `atlantic-2` following the official guides and docs leads to a node that is waiting for peers during it's whole lifetime.

- The discord is very active (but just for https://www.seinetwork.io/treasure NFT gathering) lots of people wanting SEI for doing the tasks required for the NFT claim. It really lacks of devs/sei managers that could answer things related to node operations. Lots of questions were asked by us on the `testnet-support` (even mods were tagged) and no answer at all regarding technical questions. We wanted to get a list of peers, bootnodes to connect to, in order to make the sync happen, but on the official discord there was no answer at all.
- We were lucky enough to find another node operator `brocha.in` which helped us a lot with the intrinsec knowlegde required for running a full-node/validator-node and also were kind enought to provide peers to connect to. Huge thanks to them!
- Having a node to discover peers by itself is an impossible task, so in order to make it sync we need to provide mechanisms to have the blockchain more up to date. There are currently two options, snap-sync (which downloads a snapshot and syncs the rest of the blockchain from that point), and state-sync (which 'trusts' that blockchain is good from a block, and only syncs from that point). We had more positive results with the `snap-sync` method, leading to fast syncing times, but only eventually, more on that on the next bullet.
- From our experiences, out of 10 trials made with the exact same configuration, only 3 times we ware able to have the node synced (or even start the syncing process). This experiments consited on just turning the node on/off at different times of the day, in different days. The configuration gathers the addressbook for a seed (provided by the brocha.in community), this makes it so that peers may differ every time the node gets turned on.
- Validator migration tests were also conducted, moving a validator created on a server to a different one. This tests were inconclusive, we tried first starting the node as a validator node (with a different private key) and swapping the keys to the intended one after the node is synced. For this swap to be effective the node needs to be restarted, after doing so the chain never got back in sync. This tests was made 8 times on different machines with the same result (even ones in germany in order to reduce latency, and bare-metals with huge 64 cores, 128 GB of ram, and 2TB of SSD disk). We also conducted a test (this one only was performed 2 times) starting the node as a full-node and after syncing restarting it as a validator (with migrated the private keys inplace) but we were not able to make the node sync so we couldn't finish that test.
- All and all, the network seems to be really unstable (at least the atlantic-2 testnet) and it is due to:
  - The lack of provision of trusted peers on the docs
  - The 1s block producing time doesn't help at all with this unstability, the block production time should be increased
  - The great majority of the nodes are located in central europe (germany, netherlands, etc.) this leads to high latency with other peers located outside europe







