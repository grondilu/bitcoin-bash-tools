#!/usr/bin/env bash

. bip-0032.sh

bip49() {
  BIP32_MAINNET_PUBLIC_VERSION_CODE=0x049d7cb2 \
  BIP32_MAINNET_PRIVATE_VERSION_CODE=0x049d7878 \
  BIP32_TESTNET_PUBLIC_VERSION_CODE=0x044a5262 \
  BIP32_TESTNET_PRIVATE_VERSION_CODE=0x044a4e28 \
  bip32 "$@"
}

