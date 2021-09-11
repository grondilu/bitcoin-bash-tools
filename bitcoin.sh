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

for script in {secp256k1,base58}.sh
do . "$script"
done

hash160() {
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary
}

ser256()
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{2}{32})$ ]]
  then xxd -p -r <<<"${BASH_REMATCH[2]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{,63})$ ]]
  then $FUNCNAME "0x0${BASH_REMATCH[2]}"
  else return 1
  fi

bitcoinAddress()
  if
    local OPTIND o
    getopts ht o
  then shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE_bitcoinAddress
	$FUNCNAME -h
	$FUNCNAME PUBLIC_POINT
	$FUNCNAME WIF_PRIVATE_KEY
	END_USAGE_bitcoinAddress
        ;;
      t) P2PKH_PREFIX="\x6F" $FUNCNAME "$@" ;;
    esac
  elif [[ "$1" =~ ^0([23][[:xdigit:]]{2}{32}|4[[:xdigit:]]{2}{64})$ ]]
  then
    {
      printf "${P2PKH_PREFIX:-\x00}"
      echo "$1" | xxd -p -r | hash160
    } | base58 -c
  elif [[ "$1" =~ ^[5KL] ]] && base58 -v "$1"
  then base58 -x "$1" |
    {
      read
      if [[ "$REPLY" =~ ^(80|EF)([[:xdigit:]]{2}{32})(01)?([[:xdigit:]]{2}{4})$ ]]
      then
	local point
        if test -n "${BASH_REMATCH[3]}"
        then point="$(secp256k1 "${BASH_REMATCH[2]}")"
        else point="$(secp256k1 -u "${BASH_REMATCH[2]}")"
        fi
        if [[ "$REPLY" =~ ^80 ]]
        then $FUNCNAME "$point"
        else $FUNCNAME -t "$point"
        fi
      else return 2
      fi
    }
  else return 1
  fi

newBitcoinKey()
  if 
    local OPTIND o
    getopts hut o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	$FUNCNAME -h
	$FUNCNAME [-t][-u] [PRIVATE_KEY]
        $FUNCNAME WIF
	
	The '-h' option displays this message.
	
	PRIVATE_KEY is a natural integer in decimal or hexadecimal, with an
	optional '0x' prefix for hexadecimal.
	
	WIF is a private key in Wallet Import Format.  With such argument,
	$FUNCNAME will parse it and echo the result in JSON.
	
	The '-u' option will use the uncompressed form of the public key.
        
        If no PRIVATE_KEY is provided, a random one will be generated.
	
	The '-t' option will generate addresses for the test network.
	END_USAGE
        return
        ;;
      u) BITCOIN_PUBLIC_KEY_FORMAT=uncompressed $FUNCNAME "$@";;
      t) BITCOIN_NET=TEST $FUNCNAME "$@";;
    esac
  elif [[ "$1" =~ ^[1-9][0-9]*$ ]]
  then $FUNCNAME "0x$(dc -e "16o$1p")"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,64})$ ]]
  then
    {
      if [[ "$BITCOIN_NET" = TEST ]]
      then printf "\xEF"
      else printf "\x80"
      fi
      ser256 "${BASH_REMATCH[2]^^}"
      if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" != uncompressed ]]
      then printf "\x01"
      fi
    } | base58 -c

  elif [[ "$1" =~ ^[5KL] ]] && base58 -v "$1"
  then base58 -x "$1" |
    {
      read
      if   [[ "$REPLY" =~ ^(80|EF)([[:xdigit:]]{2}{32})(01)?([[:xdigit:]]{2}{4})$ ]]
      then cat <<-JSON
	{
	  "prefix": $((0x${BASH_REMATCH[1]})),
	  "exponent"   : "${BASH_REMATCH[2]}",
	  "compression suffix": "${BASH_REMATCH[3]}",
	  "checksum": "${BASH_REMATCH[4]}"
	}
	JSON
      else return 3
      fi
    }
  elif test -z "$1"
  then $FUNCNAME "0x$(openssl rand -hex 32)"
  else
    echo unknown key format "$1" >&2
    return 2
  fi
