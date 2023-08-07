#!/bin/bash

if [ "$PRUNE_DATA" != "" ]; then
  echo "Prune data and sei folder..."

#  cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
#  cp ~/.sei/config/priv_validator_key.json ~/.sei/priv_validator_key.json.backup
#  cp ~/.sei/config/genesis.json ~/.sei/genesis.json.backup

#  rm -rf ~/.sei/data/*
#  rm -rf ~/.sei/wasm/*
#  rm -rf ~/.sei/config/priv_validator_key.json
#  rm -rf ~/.sei/config/genesis.json

#  mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json
#  mv ~/.sei/priv_validator_key.json.backup ~/.sei/config/priv_validator_key.json
#  mv ~/.sei/genesis.json.backup ~/.sei/config/genesis.json

fi

# first disable state sync and db sync
sed -i.bak -e "s|^enable *=.*|enable = false|" ~/.sei/config/config.toml
sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" ~/.sei/config/config.toml

# it prioritizes STATE_SYNC if enabled (over SNAP_SYNC)
if [ "$STATE_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then
        RPC_SERVER="https://rpc.atlantic-2.seinetwork.io"
        LATEST_HEIGHT=$(curl -s $RPC_SERVER/block | jq -r .block.header.height)
        SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 50000))
        SYNC_BLOCK_HASH=$(curl -s "$RPC_SERVER/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .block_id.hash)

        sed -i.bak -e "s|^enable *=.*|enable = true|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^use-p2p *=.*|use-p2p = true|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" ~/.sei/config/config.toml

        BOOTS_PEERS=""
        PERSISTENT_PEERS="170397e75ca2b0f4e9f3b1bb5d0d23f9b10f01c7@sei-testnet-2-sentry-1.p2p.brocha.in:30606,c0b33353fb70d8d71dcb9c8848b3b4207bd56951@sei-testnet-2-sentry-2.p2p.brocha.in:30607,f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@sei-testnet-2.seed.brocha.in:30587,052ce9ca90155b2f32bea92810ebf98968f73d1a@116.202.223.97:26656,f95c7153905d673a923c53defdcbe57145b95a53@162.55.101.182:26656,38cca3cddba68211bcbbff78508244318ae3a868@167.235.117.147:11956,fa6c991c81ce3e33e984718cf870b1a238eb4627@103.219.171.24:51656,06a80e8564b06ea5afef5ae74face1798e505572@65.109.82.230:2665,a03df99ce5b8993b7f110e9940048e48ffca042f@188.172.229.187:26656,5c34181454a371267d28fa546a4f91453417220f@136.243.70.112:11956,eab6b1f448aee8037e1bf1146b578023421d349b@167.235.119.240,ecdb789058d4a149db4409f122152cd5e66a7cab@136.243.13.36:11956,f9f898c1bfe3d29c95bf49509a292435bdc8f430@136.243.131.108:46656,cdea89573b683a1b1e2e39f641df249c38f59e48@51.195.7.5:26656,19f1cfd71747b2405dcb4a7a74d81078f654317b@5.9.147.22:26647,049629c1983b73f0a8076c9045c87289aa4c4f92@172.93.110.154:29656,39b7cfc368c95b41731f5d82c52ce35a8f0e4c14@65.109.104.118:61556,431347488bb26f53cddd672d02bd363faef97e36@162.62.225.150:26656,007f79a0c8204ea607b892f882c5a9e1550c3b7b@157.90.81.206:26656,37884d57189054d7916116bdeceb14af816e98c8@54.153.35.25:26656,28a6a9bfaf905361cfaef3d55c83b5a3bbcbfe67@52.59.200.160:26656,7f40c6e4bbc4abaf6b8f8d4e262a47eb2a018eef@162.19.95.240:26656,d8012229ef0a3336075fd9e3b80b39e8852ce1cc@141.94.193.168:27656,39d114cf5485213feabb597e57e2756418a60153@136.243.36.60:11956,e36a03acda3d371bd655402c85ed713dde252b35@43.131.17.104:26656,83710b3e5ec49ffe61418f4c89845befba8d1091@85.10.211.215:27212,20b4f9207cdc9d0310399f848f057621f7251846@141.94.248.105:26656,15a7b95830e83663444d15d6fcd2013e7def2846@sei-a2-rpc.p2p.brocha.in:30612,551af16105e8faac0327066cd0bf3072ac02510a@46.166.138.207:26656,7c3f3143aed3a8916987f86d3ca732f293794efb@74.118.139.72:11956,72b6f699cb4ab00b2b924ab8023f94396b686865@88.198.32.17:38,1d3e3c08e5a39e7f211a1b256739aa2a3704e9e1@sei-testnet.nodejumper.io:26656,f516643bb00dc73b88af8d259736b8cbdf682bab@65.109.32.174:33656,bd4b55cdd7ef9ea57a78f11cccab8f3b34aed4e6@5.9.79.118:26656,7ed5fa29a165a7b5df1707af71e3be99078080b4@5.9.78.252:26656,d0639bcd2a1fcba6bfa3e3bdbca756ed3bddec58@ec2-3-121-126-161.eu-central-1.compute.amazonaws.com:26656,36ebe3561d0cfabf64fa3102477082fe0602c964@51.77.56.42:51756,747d7e75198c5fa507e5abd9a25da19c588b4c17@sei-a2-rpc.p2p.brocha.in:30612,dfedc0a045e85c6d6938a8483681cc12dcd87fe3@rpc-2.sei.nodes.guru:51656,6947733fbac29f65e624e007c428e490dcaf4d8a@3.252.157.20:26656,56a1d17ff164627a1102528014d4d165f9862985@65.109.94.250:26656,c77ecbb674b29e47dc2e979bc42fd48c8ab0440b@222.106.187.14:54400,b4280533b90318123352c44744fc23fe96d7a32e@sei-testnet-rpc.polkachu.com:1195,6090d4c2e2f6e70718266900e3cb4b83ffa209ea@18.184.142.131:26656,940de49b88cfa0ddb8ec27bd091de643eea85ab3@88.198.52.46:11956,3fb76c4093d5348cfdf64d43f402782d653e56f4@148.251.235.130:26656,65c257f9275beb1b99ca169ef89743c034b15db0@3.76.192.224:26656,862b03573172a3366afe1cabb903ba0552689e63@198.244.228.59:1195,690477c3f8956b238119f3e8e50c8fbfa0a45e59@43.131.44.171:26656,64eeb72c928c37dab5b6c04d8e366d76c685f73f@sei-a2-rpc.p2p.brocha.in:30612,988a86e47b3a7fee3df16badefc32d9c3d7eed6f@136.243.38.85:26656,http://955f7c2e13df7af4ffde385e9e7c68634300e6aa@[2a01:4f9:1a:a718::12]:26656,49f31b3ee83ba5ac92ee1478cdd083a7abe8d6c6@65.109.58.179:51656,0065c38affbc4d3df6920e2175d81b75c46ba2b6@[2a01:4f8:271:2de9::2]:26656"
        sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$BOOTS_PEERS\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" ~/.sei/config/config.toml

        sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$RPC_SERVER,$RPC_SERVER\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^snapshot-interval *=.*|snapshot-interval = \"0\"|" ~/.sei/config/app.toml

	cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
	cp ~/.sei/config/priv_validator_key.json ~/.sei/priv_validator_key.json.backup
	cp ~/.sei/config/genesis.json ~/.sei/genesis.json.backup
	rm -rf ~/.sei/data/*
	rm -rf ~/.sei/wasm/*
	rm -rf ~/.sei/config/priv_validator_key.json
	rm -rf ~/.sei/config/genesis.json
        # Example: Set polkachu rpc as rpc-servers
        PRIMARY_ENDPOINT=https://sei-testnet-rpc.polkachu.com:443
        sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$PRIMARY_ENDPOINT,$PRIMARY_ENDPOINT\"|" ~/.sei/config/config.toml
	# Example: set trust height and hash to be the block height 10,000 earlier
	PRIMARY_ENDPOINT=https://sei-testnet-rpc.polkachu.com:443
	TRUST_HEIGHT_DELTA=50000
	LATEST_HEIGHT=$(curl -s "$PRIMARY_ENDPOINT"/block | jq -r ".block.header.height")
	if [[ "$LATEST_HEIGHT" -gt "$TRUST_HEIGHT_DELTA" ]]; then
		SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - $TRUST_HEIGHT_DELTA))
	else
		SYNC_BLOCK_HEIGHT=$LATEST_HEIGHT
	fi
	# Get trust hash
	SYNC_BLOCK_HASH=$(curl -s "$PRIMARY_ENDPOINT/block?height=$SYNC_BLOCK_HEIGHT" | jq -r ".block_id.hash")
	# Override configs
	sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
	sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
        # Example: Get the peers from polkachu rpc server
        PRIMARY_ENDPOINT=https://sei-testnet-rpc.polkachu.com:443
        SELF=$(cat /root/.sei/config/node_key.json |jq -r .id)
        curl "$PRIMARY_ENDPOINT"/net_info |jq -r '.peers[] | .url' |sed -e 's#mconn://##'|grep -v "$SELF"  > PEERS
        PERSISTENT_PEERS=$(paste -s -d ',' PEERS)
        sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" ~/.sei/config/config.toml
	# Enable state sync
	sed -i.bak -e "s|^enable *=.*|enable = true|" ~/.sei/config/config.toml
	sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" ~/.sei/config/config.toml
	# Restore the backups
	mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json
	mv ~/.sei/priv_validator_key.json.backup ~/.sei/config/priv_validator_key.json
	mv ~/.sei/genesis.json.backup ~/.sei/config/genesis.json
    fi
elif [ "$SNAP_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then
        SNAPSHOT_FILE=$(curl -Ls https://snapshots.brocha.in/sei-testnet-2/atlantic-2.json | jq -r .goleveldb.file)
        curl -L https://snapshots.brocha.in/sei-testnet-2/$SNAPSHOT_FILE | lz4 -dc - | tar -xf - -C ~/.sei
    fi
elif [ "$DB_SYNC" != "" ]; then
    echo "db-sync"
    STATE_SYNC_RPC="http://db-sync.atlantic-2.seinetwork.io:26657"
    STATE_SYNC_RPC_1="https://rpc.atlantic-2.seinetwork.io"
    LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .block.header.height)
    SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 40000))
    SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .block_id.hash)

    sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
    sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
#    sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"http://db-sync.atlantic-2.seinetwork.io:26657,http://db-sync.atlantic-2.seinetwork.io:26657\"|" ~/.sei/config/config.toml
    sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$STATE_SYNC_RPC_1,$STATE_SYNC_RPC_1\"|" ~/.sei/config/config.toml
    sed -i.bak -e "s|^enable *=.*|enable = false|" ~/.sei/config/config.toml
    sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = true|" ~/.sei/config/config.toml
    sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"\"|" ~/.sei/config/config.toml
    PERSIST_PEER_OFFICIAL_WDB_SYNC="d0639bcd2a1fcba6bfa3e3bdbca756ed3bddec58@p2p.db-sync.atlantic-2.seinetwork.io:26656"
    sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSIST_PEER_OFFICIAL_WDB_SYNC\"|" ~/.sei/config/config.toml 
    sed -i.bak -e "s|^use-p2p *=.*|use-p2p = false|" ~/.sei/config/config.toml


	cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
        cp ~/.sei/config/priv_validator_key.json ~/.sei/priv_validator_key.json.backup
        cp ~/.sei/config/genesis.json ~/.sei/genesis.json.backup

        rm -rf ~/.sei/data/*
        rm -rf ~/.sei/wasm/*
        rm -rf ~/.sei/config/priv_validator_key.json
        rm -rf ~/.sei/config/genesis.json
	# Example: Set polkachu rpc as rpc-servers
	PRIMARY_ENDPOINT=https://sei-testnet-rpc.polkachu.com:443
	sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$PRIMARY_ENDPOINT,$PRIMARY_ENDPOINT\"|" ~/.sei/config/config.toml
	# Example: set trust height and hash to be the block height 10,000 earlier
	PRIMARY_ENDPOINT=https://sei-testnet-rpc.polkachu.com:443
	TRUST_HEIGHT_DELTA=40000
	LATEST_HEIGHT=$(curl -s "$PRIMARY_ENDPOINT"/block | jq -r ".block.header.height")
	if [[ "$LATEST_HEIGHT" -gt "$TRUST_HEIGHT_DELTA" ]]; then
		SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - $TRUST_HEIGHT_DELTA))
	else
		SYNC_BLOCK_HEIGHT=$LATEST_HEIGHT
	fi
	# Get trust hash
	SYNC_BLOCK_HASH=$(curl -s "$PRIMARY_ENDPOINT/block?height=$SYNC_BLOCK_HEIGHT" | jq -r ".block_id.hash")
	# Override configs
	sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
	sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
	# Example: use sei internal db-sync node
	CHAIN_ID=atlantic-2
	NODE_ID=$(curl -s "http://db-sync.$CHAIN_ID.seinetwork.io:26657/status" | jq ".node_info.id" | tr -d '"')
	echo "$NODE_ID@db-sync.$CHAIN_ID.seinetwork.io:26656" > PEERS
	PERSISTENT_PEERS=$(paste -s -d ',' PEERS)
	sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" ~/.sei/config/config.toml
	# Enable db sync
	sed -i.bak -e "s|^enable *=.*|enable = false|" ~/.sei/config/config.toml
	sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = true|" ~/.sei/config/config.toml

        # Restore the backups
        mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json
        mv ~/.sei/priv_validator_key.json.backup ~/.sei/config/priv_validator_key.json
        mv ~/.sei/genesis.json.backup ~/.sei/config/genesis.json

elif [ "$DB_SYNC_END" != "" ]; then
    echo "end db-sync"
    sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" ~/.sei/config/config.toml
    sed -i.bak -e "s|^load-latest *=.*|load-latest = true|" ~/.sei/config/app.toml
fi

if [ "$GET_GENESIS" != "" ]; then
    curl https://raw.githubusercontent.com/sei-protocol/testnet/master/$CHAIN_ID/genesis.json > ~/.sei/config/genesis.json
fi

# Main configs
sed -i "s/moniker = \".*\"/moniker = \"$MONIKER\"/" ~/.sei/config/config.toml
sed -i "s/mode = \".*\"/mode = \"$MODE\"/" ~/.sei/config/config.toml
sed -i "s/chain-id = \".*\"/chain-id = \"$CHAIN_ID\"/" ~/.sei/config/client.toml

seid start
