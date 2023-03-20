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

```
docker-compose up -d
``` 







