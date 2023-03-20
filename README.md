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

### Step 1 - Config client 

#### config.toml 
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
# Path to the JSON file containing the private key to use as a validator in the consensus protocol
key-file = "config/priv_validator_key.json"

# Path to the JSON file containing the last sign state of a validator
state-file = "data/priv_validator_state.json"
...
# Address to listen for incoming connections
laddr = "tcp://0.0.0.0:26656"
...
# Comma separated list of peers to be added to the peer store
# on startup. Either BootstrapPeers or PersistentPeers are
# needed for peer discovery
bootstrap-peers =
...
# Comma separated list of nodes to keep persistent connections to
persistent-peers = ""
...
# Maximum number of connections (inbound and outbound).
max-connections = 200
...
# Rate limits the number of incoming connection attempts per IP address.
max-incoming-connection-attempts = 100
...
# State sync rapidly bootstraps a new node by discovering, fetching, and restoring a state machine
# snapshot from peers instead of fetching and replaying historical blocks. Requires some peers in
# the network to take and serve state machine snapshots. State sync is not attempted if the node
# has any local state (LastBlockHeight > 0). The node will have a truncated block history,
# starting from the height of the snapshot.
enable = true
...
# If using RPC, at least two addresses need to be provided. They should be compatible with net.Dial,
# for example: "host.example.com:2125"
rpc-servers = ""
...
# The hash and height of a trusted block. Must be within the trust-period.
trust-height = 3541689
trust-hash = "EA116CEA4E1FB2BBD3C8EA5EA1D0D0413369A891C9AAE58CC686CACCD9B9D81D"
```

#### client.toml
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







