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
. bip-0173.sh

. bip-0032.sh
. bip-0049.sh
. bip-0084.sh
alias xkey=bip32
alias ykey=bip49
alias zkey=bip84

. bip-0039.sh

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
      echo "$1" | xxd -p -r |
      hash160
    } | base58 -c
  elif
    base58 -v <<<"$1" && 
    [[ "$(base58 -d <<<"$1" |xxd -p -c 38)" =~ ^(80|ef)([[:xdigit:]]{64})(01)?([[:xdigit:]]{8})$ ]]
  then
    local point exponent="${BASH_REMATCH[2]^^}"
    if test -n "${BASH_REMATCH[3]}"
    then point="$(dc -f secp256k1.dc -e "lG16doi$exponent lMx lCx[0]Pp")"
    else point="$(dc -f secp256k1.dc -e "lG16doi$exponent lMx lUxP" |xxd -p -c 65)"
    fi
    if [[ "${BASH_REMATCH[1]}" = 80 ]]
    then ${FUNCNAME[0]} "$point"
    else ${FUNCNAME[0]} -t "$point"
    fi
  elif [[ "$1" =~ ^[[:alpha:]]pub ]] && base58 -v <<<"$1"
  then
    base58 -d <<<"$1" |
    head -c -4 |
    tail -c 33 |
    xxd -p -c 33 |
    {
      read
      case "${1::1}" in
        x) ${FUNCNAME[0]} "$REPLY" ;;
        t) ${FUNCNAME[0]} -t "$REPLY" ;;
        y) 
          {
            printf %b "\x05"
            {
              printf %b%b "\x00\x14"
              echo "${REPLY}" | xxd -p -r |
              hash160
            } | 
            hash160
          } | base58 -c
          ;;
        z) segwitAddress -p "$REPLY" ;;
        v) segwitAddress -t -p "$REPLY" ;;
        *)
          echo "${1::4} addresses NYI" >&2
          return 2
          ;;
      esac
    }
  else return 1
  fi
}

wif()
  if
    local OPTIND o
    getopts hutdp o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} reads 32 bytes from stdin and interprets them
	as a bitcoin private key to display in Wallet Import Format (WIF).
	
	Usage:
	  ${FUNCNAME[0]} -h
	  ${FUNCNAME[0]} -d
	  ${FUNCNAME[0]} [-t][-u]
	
	The '-h' option displays this message.
	
	The '-u' option will place a suffix indicating that the key will be
	associated with a public key in uncompressed form.
	
	The '-t' option will generate addresses for the test network.
	
	The '-d' option performs the reverse operation : it reads a key in WIF
	and prints 32 bytes on stdout.  When writing to a terminal, non-printable
	characters will be escaped.
	END_USAGE
        ;;
      d) base58 -d |
         tail -c +2 |
         head -c 32 |
         if test -t 1
         then cat -v
         else cat
         fi
         ;;
      p)
        ${FUNCNAME[0]} -d |
        {
          # see https://stackoverflow.com/questions/48101258/how-to-convert-an-ecdsa-key-to-pem-format
          xxd -p -r <<<"302E0201010420"
          cat
          xxd -p -r <<<"A00706052B8104000A"
        } |
        openssl ec -inform der
        ;;
      u) BITCOIN_PUBLIC_KEY_FORMAT=uncompressed ${FUNCNAME[0]} "$@";;
      t) BITCOIN_NET=TEST ${FUNCNAME[0]} "$@";;
    esac
  else
    {
      if [[ "$BITCOIN_NET" = TEST ]]
      then printf "\xEF"
      else printf "\x80"
      fi
      head -c 32
      if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" != uncompressed ]]
      then printf "\x01"
      fi
    } |
    base58 -c
  fi

