#!/bin/bash

sudo apt update & sudo apt install -y shc

shc -r -f scripts/sei-rewards-distribute.sh -o scripts/sei-rewards-distribute
if [[ -f scripts/sei-rewards-distribute ]]; then
    rm scripts/sei-rewards-distribute.sh.x.c scripts/sei-rewards-distribute.sh
fi