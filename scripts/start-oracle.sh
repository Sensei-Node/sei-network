#!/bin/bash

if [ "$START_ORACLE" != "" ]; then
  if [ -z "$CHAIN_ID" ]; then
    echo "CHAIN_ID is empty, exiting..."
    exit 1
  fi

  # Remove old config if existent, and copy sample
  rm -f /root/config.toml
  cp /root/oracles-config.toml /root/config.toml

  # Replace with variables values
  sed -i "s/address = \"\"/address = \"$ORACLE_SIGNER_ADDR\"/g" /root/config.toml
  sed -i "s/chain_id = \"\"/chain_id = \"$CHAIN_ID\"/g" /root/config.toml
  sed -i "s/validator = \"\"/validator = \"$VALIDATOR_ADDR\"/g" /root/config.toml

  # Start the price feeder oracle
  price-feeder /root/config.toml
fi

exit 0