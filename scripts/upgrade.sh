#!/bin/bash

# Update repo code to deisred release
cd /app && git fetch 
git checkout $UPGRADE_TAG
git pull origin $UPGRADE_TAG

# Build binaries
echo -e "\nBuilding new binaries..."
make build && make build-price-feeder
mkdir -p /root/binaries/${UPGRADE_TAG}
mv /app/build/seid /root/binaries/${UPGRADE_TAG}
mv /app/build/price-feeder /root/binaries/${UPGRADE_TAG}
rm -rf build
echo -e "\n✅ Finished building new binaries..."

# Prepare binaries for Cosmovisor
mkdir -p /root/.sei/cosmovisor/upgrades/$UPGRADE_TAG/bin
cp /root/binaries/${UPGRADE_TAG}/seid /root/.sei/cosmovisor/upgrades/$UPGRADE_TAG/bin/
cp /root/binaries/${UPGRADE_TAG}/price-feeder /root/.sei/cosmovisor/upgrades/$UPGRADE_TAG/bin/
echo -e "\n✅ Finished upgrade process..."
