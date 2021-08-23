#!/bin/bash
# Various bash bitcoin tools
#
# requires dc, the unix desktop calculator (which should be included in the
# 'bc' package)
#
# This script requires bash version 4 or above.
#
# This script uses GNU tools.  It is therefore not guaranted to work on a POSIX
# system.
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
elif [[ ! -f secp256k1.dc ]]
then
  1>&2 echo "This script requires the secp256k1 DC file"
  exit 2
fi

. bech32.sh

pack()   { echo -n "$1" | xxd -r -p; }
unpack() { xxd -p | tr -d '\n'; }

readonly -a base58=(
      1 2 3 4 5 6 7 8 9
    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h i j k   m n o p q r s t u v w x y z
)
unset dcr; for i in ${!base58[@]}; do dcr+="${i}s${base58[i]}"; done
decodeBase58() {
  echo -n "$1" | sed -e's/^\(1*\).*/\1/' -e's/1/00/g' | tr -d '\n'
  echo "$1" |
  {
    echo "$dcr 0"
    sed 's/./ 58*l&+/g'
    echo "[256 ~r d0<x]dsxx +f"
  } | dc |
  while read n
  do printf "%02X" "$n"
  done
}

encodeBase58() {
    local n
    echo -n "$1" | sed -e's/^\(\(00\)*\).*/\1/' -e's/00/1/g' | tr -d '\n'
    dc -e "16i ${1^^} [3A ~r d0<x]dsxx +f" |
    while read -r n; do echo -n "${base58[n]}"; done
}

checksum() {
    pack "$1" |
    openssl dgst -sha256 -binary |
    openssl dgst -sha256 -binary |
    unpack |
    head -c 8
}

toEthereumAddressWithChecksum() {
    local addrLower=$(sed -r -e 's/[[:upper:]]/\l&/g' <<< "$1")
    local addrHash=$(echo -n "$addrLower" | openssl dgst -sha3-256 -binary | xxd -p -c32)
    local addrChecksum=""
    local i c x
    for i in {0..39}; do
        c=${addrLower:i:1}
        x=${addrHash:i:1}
        [[ $c =~ [a-f] ]] && [[ $x =~ [89a-f] ]] && c=${c^^}
        addrChecksum+=$c
    done
    echo -n $addrChecksum
}

checkBitcoinAddress() {
    if [[ "$1" =~ ^[$(IFS= ; echo "${base58[*]}")]+$ ]]
    then
        local h="$(decodeBase58 "$1")"
        checksum "${h:0:-8}" | grep -qi "^${h:${#h}-8}$"
    else return 2
    fi
}

hash160() {
    openssl dgst -sha256 -binary |
    openssl dgst -rmd160 -binary |
    unpack
}

hexToAddress() {
    local x="$(printf "%2s%${3:-40}s" ${2:-00} $1 | sed 's/ /0/g')"
    encodeBase58 "$x$(checksum "$x")"
    echo
}

newBitcoinKey() {
    if [[ "$1" =~ ^[5KL] ]] && checkBitcoinAddress "$1"
    then
        local decoded="$(decodeBase58 "$1")"
        if [[ "$decoded" =~ ^80([0-9A-F]{64})(01)?[0-9A-F]{8}$ ]]
        then $FUNCNAME "0x${BASH_REMATCH[1]}"
        fi
    elif [[ "$1" =~ ^[0-9]+$ ]]
    then $FUNCNAME "0x$(dc -e "16o$1p")"
    elif [[ "${1^^}" =~ ^0X([0-9A-F]{1,})$ ]]
    then
        local exponent="${BASH_REMATCH[1]}"
        dc -f secp256k1.dc -e "$secp256k1 lG I16i${exponent^^}ri lMx 16olm~ n[ ]nn" |
        {
            read y x
            local full_pubkey comp_pubkey
            printf -v x "%64s" $x
            printf -v y "%64s" $y
            local X="${x// /0}" Y="${y// /0}"
            full_pubkey="04$X$Y"
            if [[ "$y" =~ [02468ACE]$ ]] 
            then comp_pubkey="02$X"
            else comp_pubkey="03$X"
            fi
            # Note: Witness uses only compressed public key
            pkh="$(pack "$comp_pubkey" | hash160)"
            ethereum_addr="$(pack "$X$Y" | openssl dgst -sha3-256 -binary | unpack | tail -c 40)"
            cat <<-EOF
		---
		secret exponent:          0x$exponent
		    public key:
		        X:                $X
		        Y:                $Y

		compressed addresses:
		    WIF:                  $(hexToAddress "${exponent}01" 80 66)
		    Bitcoin (P2PKH):      $(hexToAddress "$(pack "$comp_pubkey" | hash160)")
		    Bitcoin (P2SH [PKH]): $(hexToAddress "$(pack "21${comp_pubkey}AC" | hash160)" 05)
		    Bitcoin (P2WPKH):     $(hexToAddress "$(pack "0014$pkh" | hash160)" 05)
		    Bitcoin (1-of-1):     $(hexToAddress "$(pack "5121${comp_pubkey}51AE" | hash160)" 05)
		    # other networks
		    Qtum:                 $(hexToAddress "$pkh" 3a)

		uncompressed addresses:
		    WIF:                  $(hexToAddress "$exponent" 80 64)
		    Bitcoin (P2PKH):      $(hexToAddress "$(pack "$full_pubkey" | hash160)")
		    Bitcoin (P2SH [PKH]): $(hexToAddress "$(pack "41${full_pubkey}AC" | hash160)" 05)
		    Bitcoin (1-of-1):     $(hexToAddress "$(pack "5141${full_pubkey}51AE" | hash160)" 05)
		    Bech32 (EXPERIMENTAL!! DO NOT USE YET): $(segwit_encode bc 0 "$pkh")
		    # other networks
		    Ethereum:             0x$(toEthereumAddressWithChecksum $ethereum_addr)
		    Tron:                 $(hexToAddress "$ethereum_addr" 41)
		EOF
        }
    elif test -z "$1"
    then $FUNCNAME "0x$(openssl rand -rand <(date +%s%N; ps -ef) -hex 32 2>&-)"
    else
        echo unknown key format "$1" >&2
        return 2
    fi
}

vanityAddressFromPublicPoint() {
    if [[ "$1" =~ ^04([0-9A-F]{64})([0-9A-F]{64})$ ]]
    then
        dc -f secp256k1.dc -e "16o
        0 ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} rlp*+
        [lGlAxdlm~rn[ ]nn[ ]nr1+prlLx]dsLx
        " |
        while read -r x y n
        do
            local public_key="$(printf "04%64s%64s" $x $y | sed 's/ /0/g')"
            local h="$(pack "$public_key" | hash160)"
            local addr="$(hexToAddress "$h")"
            if [[ "$addr" =~ "$2" ]]
            then
                echo "FOUND! $n: $addr"
                return
            else echo "$n: $addr"
            fi
        done
    else
        echo unexpected format for public point >&2
        return 1
    fi
}
