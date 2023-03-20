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

### Config client 

### config.toml 
This configure the general settings like : 
```
A custom human readable name for this node
moniker = 
...
# Mode of Node: full | validator | seed
# * validator node
#   - all reactors
#   - with priv_validator_key.json, priv_validator_state.json
# * full node
#   - all reactors
#   - No priv_validator_key.json, priv_validator_state.json
# * seed node
#   - only P2P, PEX Reactor
#   - No priv_validator_key.json, priv_validator_state.json
mode = "validator"
...
# Database directory
db-dir = "data"
...
# Path to the JSON file containing the initial validator set and other meta data
genesis-file = "config/genesis.json"
...

```

### client.toml
```
# The network chain ID
chain-id = "atlantic-2"
# The keyring's backend, where the keys are stored (os|file|kwallet|pass|test|memory)
keyring-backend = "os"
# CLI output format (text|json)
output = "text"
# <host>:<port> to Tendermint RPC interface for this chain
node = "tcp://0.0.0.0:26657"
# Transaction broadcasting mode (sync|async|block)
broadcast-mode = "sync"
``` 

```
docker-compose up -d
``` 




