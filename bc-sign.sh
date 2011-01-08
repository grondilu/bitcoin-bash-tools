#!/bin/bash
#
# bitcoin signing script
#
# requires bc_key (https://github.com/dirtyfilthy/bc_key)

. base58.sh

if [[ -z "$1" ]]
then
    echo "Usage: $0  bitcoinaddress [wallet]" 2>&1
    exit 1
elif
    addr="$1"  wallet="${2:-$HOME/.bitcoin/wallet.dat}"
    [[ ! "$bitcoinaddress" =~ $bitcoinregex ]]
then
    echo "Wrong format for bitcoin address" 2>&1
    exit 2
elif ! which bc_key >/dev/null
then
    echo "Please install bitcoin key extractor" 2>&1
    exit 3
elif ! which bc >/dev/null
then
    echo "Please install bc (basic calculator)" 2>&1
    exit 4
else
    openssl dgst -sha256 -sign <(bc_key "$addr" "$wallet") |
    xxd -p 

    bc_key "$addr" "$wallet" |
    openssl ec -pubout 2>/dev/null
fi
