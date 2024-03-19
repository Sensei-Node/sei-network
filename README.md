# [Sei-Network Protocol](https://www.seinetwork.io/)

## General 

Sei is the first sector-specific Layer 1 blockchain, specialized for trading and descentralized exchanges. 

This repository contains a Dockerfile which installs, configures and runs the node looking for the latest snapshot or using the StateSync function for faster syncronization with the network. 


## Instructions

```
git clone https://github.com/Sensei-Node/sei-network
cd sei-network
``` 

### Setup .env file

Make a copy of the `.env-default` to `.env` and modify it according to your node neccesities. Note: DOWNLOAD_SNAPSHOT is only available for pacific-1 mainnet.

```
# ------------------------------------ NODE VARIABLES ------------------------------------

# Github release tag
REL_TAG=v3.8.0

# For validator recognition
MONIKER=
# Chain id atlantic-2, pacific-1
CHAIN_ID=
# Node operation mode: full, validator, etc.
MODE=

# Node folder structure initialization
INIT_NODE=
# For wiping database, first backing up priv-val-state.json
PRUNE_DATA=

# If you want to include specific peers add them here
# NOTICE: needs to be in a row format (because it gets pruned if current node is the peer specified)
INCLUDE_PEERS="node_id@ip:port
node_id_2@ip:port"

# If you want to use state sync (available for testnet and mainnet)
USE_STATE_SYNC=

# If you want to use snapshot sync (only available for mainnet)
USE_SNAPSHOTS=

# If you want to set up a validator node with a sentry, the validator peer should be specified here
# in order not to be broadcasted to the network
# TO BE IMPLEMENTED
PRIVATE_PEER=

# ------------------------------------ ORACLE VARIABLES ------------------------------------

# Start ORACLE for price feeds: set to anything different than empty
START_ORACLE=
# Keyring password of the oracle account
PRICE_FEEDER_PASS=
# Address of the oracle signer, this account should have some sei in order to pay for gas fees
# Also, thi address should be imported into the node, and the keyring password should be the one 
# specified above
ORACLE_SIGNER_ADDR=
# The validator related to the oracle
VALIDATOR_ADDR=
```

### Run the node

```
docker-compose up -d
``` 

### How to get the node in sync

There are two avilable options for syncing the node rapidly, one way (and in our opinion the best) is using `state sync` the project is prepared in a way that you could use this syncing method for both `pacific-1` mainnet and `atlantic-2` testnet.
The other way of syncing (only available for `pacific-1`) is via snapshots. In order to make use of each method the variables `USE_STATE_SYNC` or `USE_SNAPSHOTS` (in conjunction with `INIT_NODE`) should be set to anything different that empty.
After the node starts, the variable `INIT_NODE` should be commented out or left blank (otherwise it will be reinitialized again and syncing process would start from zero).

Also, having the proper bootnodes is key for having a synced node. If this list is not provided (or has peers that are offline/behind) the node wont be able to start syncing ever. Also it is not recommended to set up the `persistent-peers` variable inside the `config.toml` file, you should rather use the `bootstrap-peers` variable instead.

### Cosmovisor usage

There are some variables that need to be included in order to use cosmovisor as launcher, these could be included in the same `.env` file:

```
USE_COSMOVISOR=true
COSMOVISOR_TAG=v1.3.0
DAEMON_HOME=/root/.sei
DAEMON_NAME=seid
UNSAFE_SKIP_BACKUP=true
DAEMON_RESTART_AFTER_UPGRADE=true
DAEMON_ALLOW_DOWNLOAD_BINARIES=false
```

---

## Useful data

### How to get validator out of jail

`seid tx slashing unjail --from admin --fees 2000usei -b block -y`

### How to modify validator commission

`seid tx staking edit-validator --commission-rate="0" --chain-id="atlantic-2" --from="admin" --fees="2000usei"`

### Helper for getting blocks to sync

```
getSyncSei() {
  json=$(docker exec -it sei-network-sei-1 seid status -n tcp://localhost:26657) ; latest_block_height=$(echo "$json" | jq -r '.SyncInfo.latest_block_height'); max_peer_block_height=$(echo "$json" | jq -r '.SyncInfo.max_peer_block_height'); difference=$((max_peer_block_height-latest_block_height)); echo $(date): $difference
}
```

### How to migrate validator to another node

1. Get a copy of `/sei/XXX.address` and `XXX.info`: these files are required for the validator management (the wallet used for creating the validator)
2. Get a copy of `/sei/config/priv_validator_key.json`: this file is a must, this is the validator private key
3. Get a copy of latest `/sei/data/priv_validator_state.json`: this file determines the last signature, if the validator was active it is mandatory to have this file not to incurse in double signing

After getting these files just replace on the destination validator server (once it is fully synced). 

**NOTE: make sure to stop previous validator before creating a copy of the file `/sei/data/priv_validator_state.json`**

### How to setup validator identity and details

Identity is just your keybase account, make sure to upload a profile picture.

```
seid tx staking edit-validator \
    --identity="keybase_account_name" \
    --details="Whatever you wish to include as description" \
    --chain-id=$CHAIN_ID \
    --from=$ACCOUNT_NAME \
    --fees="200000usei" \
    -y --node tcp://localhost:26657
```

### More useful commands

- https://services.kjnodes.com/mainnet/sei/useful-commands/
