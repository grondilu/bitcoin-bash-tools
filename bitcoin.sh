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

for script in {secp256k1,base58,bip-{0173,0032}}.sh
do . "$script"
done

hash160() {
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary
}

ser256()
  if   [[ "$1" =~ ^0x([[:xdigit:]]{2}{32})$ ]]
  then xxd -p -r <<<"${BASH_REMATCH[1]}"
  elif [[ "$1" =~ ^0x([[:xdigit:]]{,63})$ ]]
  then $FUNCNAME "0x0${BASH_REMATCH[1]}"
  else return 1
  fi

newBitcoinKey()
  if [[ "$1" =~ ^[1-9][0-9]*$ ]]
  then $FUNCNAME "0x$(dc -e "16o$1p")"
  elif [[ "$1" =~ ^0x[[:xdigit:]]+$ ]]
  then
    local exponent="$1"
    local pubkey="$(secp256k1 "$exponent")"
    local pubkey_uncompressed="$(secp256k1 -u "$pubkey")"
    local WIF_PREFIX="\x80" P2PKH_PREFIX="\x00" P2SH_PREFIX="\x05" BECH32_PREFIX="bc"
    if [[ "$BITCOIN_NET" = 'TEST' ]]
    then WIF_PREFIX="\xEF" P2PKH_PREFIX="\x6F" P2SH_PREFIX="\xC4" BECH32_PREFIX="tb"
    fi
    cat <<-ENDJSON
	{
	  "compressed": {
	    "WIF": "$({
	      printf "$WIF_PREFIX"
	      ser256 "$exponent"
	      printf "\x01"
	      } | base58 -c)",
	    "addresses": {
	      "p2pkh": "$({
	        printf "$P2PKH_PREFIX"
	        echo "$pubkey" | xxd -p -r | hash160
	      } | base58 -c)",
	      "p2sh":  "$({
	        printf "$P2SH_PREFIX"
	        echo "21${pubkey}AC" | xxd -p -r | hash160
	      } | base58 -c)",
	      "bech32": "$(
	        echo "$pubkey" | xxd -p -r | hash160 |
	        segwit_encode "$BECH32_PREFIX" 0
	      )"
	    }
	  },
	  "uncompressed": {
	    "WIF": "$({
	      printf "$WIF_PREFIX"
	      ser256 "$exponent"
	      } | base58 -c)",
	    "addresses": {
	      "p2pkh": "$({
	        printf "$P2PKH_PREFIX"
	        echo "$pubkey_uncompressed" | xxd -p -r | hash160
	      } | base58 -c)",
	      "p2sh": "$({
	        printf "$BECH32_PREFIX"
	        echo "41${pubkey_uncompressed}AC" | xxd -p -r | hash160
	      } | base58 -c)"
	    }
	  }
	}
	ENDJSON
  elif test -z "$1"
  then $FUNCNAME "0x$(openssl rand -hex 32)"
  else
      echo unknown key format "$1" >&2
      return 2
  fi
