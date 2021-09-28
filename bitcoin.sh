#!/usr/bin/env bash
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

. base58.sh

hash160() {
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary
}

ser256() {
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{64})$ ]]
  then xxd -p -r <<<"${BASH_REMATCH[2]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{,63})$ ]]
  then ${FUNCNAME[0]} "0x0${BASH_REMATCH[2]}"
  else return 1
  fi
}

bitcoinAddress() {
  local OPTIND o
  if getopts ht o
  then shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE_bitcoinAddress
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} PUBLIC_POINT
	${FUNCNAME[0]} WIF_PRIVATE_KEY
	${FUNCNAME[0]} PUBLIC_EXTENDED_KEY
	END_USAGE_bitcoinAddress
        ;;
      t) P2PKH_PREFIX="\x6F" ${FUNCNAME[0]} "$@" ;;
    esac
  elif [[ "$1" =~ ^0([23]([[:xdigit:]]{2}){32}|4([[:xdigit:]]{2}){64})$ ]]
  then
    {
      printf %b "${P2PKH_PREFIX:-\x00}"
      echo "$1" | xxd -p -r | hash160
    } | base58 -c
  elif [[ "$1" =~ ^[5KL] ]] && base58 -v "$1"
  then
    base58 -x "$1" |
    {
      read -r
      if [[ "$REPLY" =~ ^(80|EF)([[:xdigit:]]{64})(01)?([[:xdigit:]]{8})$ ]]
      then
	local point exponent="${BASH_REMATCH[2]^^}"
        if test -n "${BASH_REMATCH[3]}"
        then point="$(dc -f secp256k1.dc -e "lG16doi$exponent lMx lCx[0]Pp")"
        else point="$(dc -f secp256k1.dc -e "lG16doi$exponent lMx lUxP" |xxd -p -c 130)"
        fi
        if [[ "$REPLY" =~ ^80 ]]
        then ${FUNCNAME[0]} "$point"
        else ${FUNCNAME[0]} -t "$point"
        fi
      else return 2
      fi
    }
  elif [[ "$1" =~ ^[xt]pub ]] && base58 -v "$1"
  then
    base58 -d "$1" |
    head -c -4 |
    tail -c 33 |
    xxd -p -c 33 | 
    { read; ${FUNCNAME[0]} "$REPLY"; }
  else return 1
  fi
}

newBitcoinKey() {
  local OPTIND o
  if getopts hut o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} [-t][-u] [PRIVATE_KEY]
        ${FUNCNAME[0]} WIF
	
	The '-h' option displays this message.
	
	PRIVATE_KEY is a natural integer in decimal or hexadecimal, with an
	optional '0x' prefix for hexadecimal.
	
	WIF is a private key in Wallet Import Format.	
	
	The '-u' option will use the uncompressed form of the public key.
        
        If no PRIVATE_KEY is provided, a random one will be generated.
	
	The '-t' option will generate addresses for the test network.
	END_USAGE
        return
        ;;
      u) BITCOIN_PUBLIC_KEY_FORMAT=uncompressed ${FUNCNAME[0]} "$@";;
      t) BITCOIN_NET=TEST ${FUNCNAME[0]} "$@";;
    esac
  elif [[ "$1" =~ ^[1-9][0-9]*$ ]]
  then ${FUNCNAME[0]} "0x$(dc -e "16o$1p")"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,64})$ ]]
  then
    local hex="${BASH_REMATCH[2]^^}"
    {
      if [[ "$BITCOIN_NET" = TEST ]]
      then printf "\xEF"
      else printf "\x80"
      fi
      ser256 "$hex"
      if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" != uncompressed ]]
      then printf "\x01"
      fi
    } | base58 -c

    bitcoinAddress  "$(dc -f secp256k1.dc -e "lG16doi$hex lMx lCx[0]Pp")"
 
    while ((${#hex} != 64))
    do hex="0$hex"
    done
    
    # see https://stackoverflow.com/questions/48101258/how-to-convert-an-ecdsa-key-to-pem-format
    if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" = uncompressed ]]
    then
      xxd -p -r <<<"30740201010420${hex}A00706052B8104000AA144034200"
      dc -f secp256k1.dc -e "lG16i$hex lMx l< 2*2^+P"
    else
      xxd -p -r <<<"30540201010420${hex}A00706052B8104000AA124032200"
      dc -f secp256k1.dc -e "lG16i$hex lMx lCx P"
    fi |
    openssl ec -inform der -check

  elif [[ "$1" =~ ^[5KL] ]] && base58 -v "$1"
  then base58 -x "$1" |
    {
      read -r
      if   [[ "$REPLY" =~ ^(80|EF)([[:xdigit:]]{64})(01)?([[:xdigit:]]{8})$ ]]
      then ${FUNCNAME[0]} "0x${BASH_REMATCH[2]}"
      else return 3
      fi
    }
  elif test -z "$1"
  then ${FUNCNAME[0]} "0x$(openssl rand -hex 32)"
  else
    echo unknown key format "$1" >&2
    return 2
  fi
}
