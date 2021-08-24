#!/bin/bash
# Various bash bitcoin tools
#
# This script uses GNU tools.  It is therefore not guaranted to work on a POSIX
# system.
#
# Requirements are detailed in the accompanying README file.
#
# Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if ((BASH_VERSINFO[0] < 4))
then
  echo "This script requires bash version 4 or above." >&2
  exit 1
else
  for script in {secp256k1,base58,bip-{0173,0032}}.sh
  do 
    if ! . "$script"
    then
      1>&2 echo "This script requires the $script script file."
      exit 2
    fi
  done
  for prog in dc jq openssl
  do
    if ! which $prog >/dev/null
    then
      1>&2 echo "This script requires the $prog program."
      exit 3
    fi
  done
fi

hash160() {
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary
}

bitcoin_test() [[ "$BITCOIN_NET" = 'TEST' ]]

newBitcoinKey() {
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]
    then $FUNCNAME "0x$(dc -e "16o$1p")"
    elif [[ "$1" =~ ^0x[[:xdigit:]]+$ ]]
    then
        local exponent="$1"
        local pubkey="$(point "$exponent")"
        local pubkey_uncompressed="$(uncompressPoint "$pubkey")"
        declare -A prefixes
        if bitcoin_test
        then
           prefixes[wif]="\xEF"
           prefixes[p2pkh]="\x6F"
           prefixes[p2sh]="\xC4"
           prefixes[bech32]="tb"
        else
           prefixes[wif]="\x80"
           prefixes[p2pkh]="\x00"
           prefixes[p2sh]="\x05"
           prefixes[bech32]="bc"
        fi
        jq . <<-ENDJSON
	{
	  "compressed": {
	    "WIF": "$({
	      printf "${prefixes[wif]}"
	      ser256 "$exponent"
              printf "\x01"
	      } | encodeBase58Check)",
	    "addresses": {
	      "p2pkh": "$({
	        printf "${prefixes[p2pkh]}"
	        echo "$pubkey" | xxd -p -r | hash160
	      } | encodeBase58Check)",
	      "p2sh":  "$({
	        printf "${prefixes[p2sh]}"
	        echo "21${pubkey}AC" | xxd -p -r | hash160
	      } | encodeBase58Check)",
	      "bech32": "$(
	        echo "$pubkey" | xxd -p -r | hash160 |
	        segwit_encode "${prefixes[bech32]}" 0
	      )"
	    }
	  },
	  "uncompressed": {
	    "WIF": "$({
	      printf "${prefixes[wif]}"
	      ser256 "$exponent"
	      } | encodeBase58Check)",
	    "addresses": {
	      "p2pkh": "$({
	        printf "${prefixes[p2pkh]}"
	        echo "$pubkey_uncompressed" | xxd -p -r | hash160
	      } | encodeBase58Check)",
	      "p2sh": "$({
	        printf "${prefixes[p2sh]}"
	        echo "41${pubkey_uncompressed}AC" | xxd -p -r | hash160
	      } | encodeBase58Check)"
	    }
	  }
	}
	ENDJSON
    elif [[ "$1" = '-m' ]]
    then
      openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
      xxd -p -u -c64 |
      {
	read
	local exponent="${REPLY:0:64}" chainCode="${REPLY:64:64}"
        if bitcoin_test
        then ser32 $BIP32_TESTNET_PRIVATE_VERSION_CODE
        else ser32 $BIP32_MAINNET_PRIVATE_VERSION_CODE
        fi
        printf "\x00"      # depth
        ser32 0            # parent's fingerprint is zero for master keys
        ser32 0            # child number is zero for master keys
        ser256 "$chainCode"
        printf "\x00"; ser256 "$exponent"
      } | encodeBase58Check
    elif test -z "$1"
    then $FUNCNAME "0x$(openssl rand -hex 32)"
    else
        echo unknown key format "$1" >&2
        return 2
    fi
}

# toEthereumAddressWithChecksum() {
#     local addrLower=$(sed -r -e 's/[[:upper:]]/\l&/g' <<< "$1")
#     local addrHash=$(echo -n "$addrLower" | openssl dgst -sha3-256 -binary | xxd -p -c32)
#     local addrChecksum=""
#     local i c x
#     for i in {0..39}; do
#         c=${addrLower:i:1}
#         x=${addrHash:i:1}
#         [[ $c =~ [a-f] ]] && [[ $x =~ [89a-f] ]] && c=${c^^}
#         addrChecksum+=$c
#     done
#     echo -n $addrChecksum
# }

