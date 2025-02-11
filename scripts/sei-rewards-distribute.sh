#!/bin/bash

export AWS_ACCESS_KEY_ID=<put-your-acces-key-here>
export AWS_SECRET_ACCESS_KEY=<put-your-secret-key-here>
export AWS_DEFAULT_REGION=<put-the-region-here>

if [[ -z "$VALIDATOR_ADDR" ]]; then
	echo "You must type an validator address"
	exit
fi

# Get the passphrase from AWS Secrets Manager
PASSPHRASE=$(aws secretsmanager get-secret-value --secret-id sei_oz_val1_main --query SecretString --output text)

# Run the docker command and provide the passphrase from the variable
echo ${PASSPHRASE} | seid tx distribution withdraw-rewards ${VALIDATOR_ADDR} --commission --from openzeppelin --chain-id pacific-1 --gas-adjustment 1.4 --gas auto --gas-prices 0.02usei -y

# Unset the passphrase variable
unset PASSPHRASE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION SEI_WALLET_ADDRESS