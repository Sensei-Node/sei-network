#!/bin/bash

if [ "$PRUNE_DATA" != "" ]; then
  echo "prune data folder..."
  cp ~/.sei/data/priv_validator_state.json ~/.sei/priv_validator_state.json.backup
  rm -rf ~/.sei/data/*
  mv ~/.sei/priv_validator_state.json.backup ~/.sei/data/priv_validator_state.json
  cat ~/.sei/data/priv_validator_state.json
fi

# first disable state sync and db sync
sed -i.bak -e "s|^enable *=.*|enable = false|" ~/.sei/config/config.toml
sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" ~/.sei/config/config.toml

# it prioritizes STATE_SYNC if enabled (over SNAP_SYNC)
if [ "$STATE_SYNC" != "" ]; then
    if [ "$CHAIN_ID" == "atlantic-2" ]; then
        RPC_SERVER="https://rpc.atlantic-2.seinetwork.io"
        LATEST_HEIGHT=$(curl -s $RPC_SERVER/block | jq -r .block.header.height)
        SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 20000))
        SYNC_BLOCK_HASH=$(curl -s "$RPC_SERVER/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .block_id.hash)

        sed -i.bak -e "s|^enable *=.*|enable = true|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^use-p2p *=.*|use-p2p = true|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^db-sync-enable *=.*|db-sync-enable = false|" ~/.sei/config/config.toml

        echo "Trust config:"
        cat ~/.sei/config/config.toml | grep trust-height
        cat ~/.sei/config/config.toml | grep trust-hash

#        BOOTS_PEERS=$(curl -sS https://raw.githubusercontent.com/AlexToTheMoon/AM-Solutions/main/files/atlantic-2-bpeers.txt)
        BOOTS_PEERS=""
        PERSISTENT_PEERS="d0639bcd2a1fcba6bfa3e3bdbca756ed3bddec58@p2p.db-sync.atlantic-2.seinetwork.io:26656,eab6b1f448aee8037e1bf1146b578023421d349b@167.235.119.240:26656,cdea89573b683a1b1e2e39f641df249c38f59e48@51.195.7.5:26656,bbca143b7ee218303fd82a400ae6354d2ca934a5@51.195.61.36:51756,f95c7153905d673a923c53defdcbe57145b95a53@162.55.101.182:26656,39d114cf5485213feabb597e57e2756418a60153@136.243.36.60:11956,38cca3cddba68211bcbbff78508244318ae3a868@167.235.117.147:11956,7f40c6e4bbc4abaf6b8f8d4e262a47eb2a018eef@162.19.95.240:26656,2c9ee2596021eabc24e9501389f280dab62b3b30@213.133.100.190:509,862b03573172a3366afe1cabb903ba0552689e63@198.244.228.59:11956,38f2077d860a7aa7516fe75244c5b786fd31b9ca@162.19.86.206:26656,bd4b55cdd7ef9ea57a78f11cccab8f3b34aed4e6@5.9.79.118:2665,052ce9ca90155b2f32bea92810ebf98968f73d1a@116.202.223.97:2665,d8012229ef0a3336075fd9e3b80b39e8852ce1cc@141.94.193.168:27656,8f103332f4b63cc77dda3f3df0dba41ed532514f@45.143.196.106:26656,c0b33353fb70d8d71dcb9c8848b3b4207bd56951@sei-testnet-2-sentry-2.p2p.brocha.in:30607,802bd5bebded432a15e83a5cd74a4fb4a8e5a576@65.109.125.103:26656,690477c3f8956b238119f3e8e50c8fbfa0a45e59@43.131.44.171:26656,f516643bb00dc73b88af8d259736b8cbdf682bab@65.109.32.174:33656,170397e75ca2b0f4e9f3b1bb5d0d23f9b10f01c7@sei-testnet-2-sentry-1.p2p.brocha.in:30606,7c3f3143aed3a8916987f86d3ca732f293794efb@74.118.139.72:11956,0dcce954ad68259aa376d2a0cdc6581d74c0fa12@sei-testnet-2-rpc-2.p2p.brocha.in:30591,20b4f9207cdc9d0310399f848f057621f7251846@23.81.180.195:26656,79389ef8775ad3310b77fcd935db30f32b5ba764@65.108.136.152:28656,594a2513fe85bf5ce9b39ca63f187cad51bea594@65.21.133.125:36656,65c257f9275beb1b99ca169ef89743c034b15db0@3.76.192.224:26656,a471989d373117c1332303fc8d372fa99c572c48@tendermint-0-new-testnet.sei.sandbox.levana.finance:26656,6090d4c2e2f6e70718266900e3cb4b83ffa209ea@18.184.142.131:26656,http://94b63fddfc78230f51aeb7ac34b9fb86bd042a77@sei-state-sync.sei-testnet-2:26656,5710d992d9c33b01c3b23df4cbd715e9b4c7b46b@3.71.0.14:26656,c77ecbb674b29e47dc2e979bc42fd48c8ab0440b@127.0.0.1:54400,6bfeb8d02f6a01c492c8d169b1d53ede238bff17@65.109.60.43:3665,7ed5fa29a165a7b5df1707af71e3be99078080b4@5.9.78.252:26656,dfedc0a045e85c6d6938a8483681cc12dcd87fe3@141.94.73.39:51656,http://a9ca550057dc58ebbb5fc4e111d15ab57749344d@51.159.133.123:26656,3fb76c4093d5348cfdf64d43f402782d653e56f4@148.251.235.130:26656,177b78b894c6fd4e951a5d6173bb3f218af3d0c9@sei-a2-rpc.p2p.brocha.in:30612,9d5ba4fabef51ac7eaf76c1191b805ee8b901dbd@51.77.56.42:51756,007f79a0c8204ea607b892f882c5a9e1550c3b7b@157.90.81.206:26656,37bee40881a13a056d978b3228d9efbae8dbb6fa@51.91.70.90:51656,723ae61077afe0306bb22dfb77e684ccc71c8cca@sei-a2-rpc.p2p.brocha.in:30612,1d3e3c08e5a39e7f211a1b256739aa2a3704e9e1@sei-testnet.nodejumper.io,f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@sei-testnet-2.seed.brocha.in:30587,06a80e8564b06ea5afef5ae74face1798e505572@65.109.82.230:2665,add31b1a13d61427bc8097970a8c92410be3d96b@136.243.131.108:26656,940de49b88cfa0ddb8ec27bd091de643eea85ab3@88.198.52.46:11956,2338ccf90b73980120f27352a94ee3691bd06255@65.109.87.88:26646,f2aa346eea7cad16fa1ba063a6125ca3a1a82031@5.9.83.154:26656,965c421affb504e5a6095817303e1eb450f20b95@46.166.143.85:26656,a62894db2e6b6ca0f39a5c82693f8837122ab4a1@141.94.193.175:51656"
#        BOOTS_PEERS="94b63fddfc78230f51aeb7ac34b9fb86bd042a77@sei-testnet-2.p2p.brocha.in:30588"
        sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$BOOTS_PEERS\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" ~/.sei/config/config.toml
#        sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"7f40c6e4bbc4abaf6b8f8d4e262a47eb2a018eef@162.19.95.240:26656\"|" ~/.sei/config/config.toml

        sed -i.bak -e "s|^rpc-servers *=.*|rpc-servers = \"$RPC_SERVER,$RPC_SERVER\"|" ~/.sei/config/config.toml
        sed -i.bak -e "s|^snapshot-interval *=.*|snapshot-interval = \"0\"|" ~/.sei/config/app.toml

#        seid tendermint unsafe-reset-all --home /root/.sei
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
    SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 10000))
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
