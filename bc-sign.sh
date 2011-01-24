#!/bin/bash
#
# bitcoin signing script
#
# requires bc_key (https://github.com/dirtyfilthy/bc_key)

. $HOME/bin/base58.sh

error() { echo "${@:2}" 2>&1; exit $1; }

if [[ -z "$1" ]]
then error 1 "Usage: $0  bitcoinaddress [wallet]"
elif
    addr="$1"  wallet="${2:-$HOME/.bitcoin/wallet.dat}"
    ! checkBitcoinAddress "$addr"
then error 2 "Invalid bitcoin address"
elif ! which bc_key >/dev/null
then error 3 "Please install bitcoin key extractor"
elif ! which bc >/dev/null
then error 4 "Please install bc (basic calculator)" 
else
    privkey="$(bc_key "$addr" "$wallet")"
    openssl dgst -sha256 -sign <(echo "$privkey") -hex |
    sed 's/.* \s*//'

    openssl ec -pubout 2>&- <<<"$privkey"
fi
