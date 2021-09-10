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

newBitcoinKey()
  if
    local OPTIND o
    getopts hu o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	$FUNCNAME -h
	$FUNCNAME [-u] EXPONENT
	
	The '-h' option displays this message.
	
	EXPONENT is a natural integer in decimal or hexadecimal,
	with an optional '0x' prefix for hexadecimal.
	
	The '-u' will use the uncompressed form of the public key.
	END_USAGE
        return
        ;;
      u) BITCOIN_PUBLIC_KEY_FORMAT=uncompressed $FUNCNAME "$@";;
    esac
  elif [[ "$1" =~ ^[1-9][0-9]*$ ]]
  then $FUNCNAME "0x$(dc -e "16o$1p")"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,64})$ ]]
  then
    local exponent="${BASH_REMATCH[2]^^}" pubkey WIF_SUFFIX
    local WIF_PREFIX="\x80" P2PKH_PREFIX="\x00"
    if [[ "$BITCOIN_NET" = 'TEST' ]]
    then WIF_PREFIX="\xEF" P2PKH_PREFIX="\x6F"
    fi
    if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" = uncompressed ]]
    then
      pubkey="$(secp256k1 -u "$exponent")"
      WIF_SUFFIX=''
    else
      pubkey="$(secp256k1 "$exponent")"
      WIF_SUFFIX="\x01"
    fi
    cat <<-ENDJSON
	{
	  "WIF": "$({
	    printf "$WIF_PREFIX"
	    ser256 "$exponent"
	    printf "$WIF_SUFFIX"
	    } | base58 -c)",
	  "p2pkh": "$({
	    printf "$P2PKH_PREFIX"
	    echo "$pubkey" | xxd -p -r | hash160
	    } | base58 -c)"
	}
	ENDJSON
  elif test -z "$1"
  then $FUNCNAME "0x$(openssl rand -hex 32)"
  else
    echo unknown key format "$1" >&2
    return 2
  fi
