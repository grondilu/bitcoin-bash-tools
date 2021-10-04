#!/usr/env/bin bash

# Translated from javascript.
#
# Original code links:
# https://github.com/sipa/bech32/blob/master/ref/javascript/bech32.js
# https://github.com/sipa/bech32/blob/master/ref/javascript/segwit_addr.js
#
# Original copyright notice :
#
# // Copyright (c) 2017, 2021 Pieter Wuille
# //
# // Permission is hereby granted, free of charge, to any person obtaining a copy
# // of this software and associated documentation files (the "Software"), to deal
# // in the Software without restriction, including without limitation the rights
# // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# // copies of the Software, and to permit persons to whom the Software is
# // furnished to do so, subject to the following conditions:
# //
# // The above copyright notice and this permission notice shall be included in
# // all copies or substantial portions of the Software.
# //
# // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# // THE SOFTWARE.
# 

if ! test -v bech32_sh
then . bech32.sh
fi

convertbits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  local -i maxv="$(( (1 << outbits) - 1 ))"
  while read 
  do
    val=$(((val<<inbits)|$REPLY))
    ((bits+=inbits))
    while ((bits >= outbits))
    do
      (( bits-=outbits ))
      echo $(( (val >> bits) & maxv ))
    done
  done
  if ((pad > 0))
  then
    if ((bits))
    then echo $(( (val << (outbits - bits)) & maxv ))
    fi
  elif (( ((val << (outbits - bits)) & maxv ) || bits >= inbits))
  then return 1
  fi
}

segwit_decode() {
  local addr="$1"
  if ! {
      bech32_decode "$addr" ||
      bech32_decode -m "$addr" 
    } >/dev/null
  then return 1
  else
    {
      bech32_decode "$addr" ||
      bech32_decode -m "$addr" 
    } |
    {
      local hrp
      read hrp
      if [[ ! "$hrp" =~ ^(bc|tb)$ ]]
      then return 2
      fi
      local -i version
      read version
      if ((version > 0)) && bech32_decode "$addr" >/dev/null
      then return 3
      elif ((version == 0)) && bech32_decode -m "$addr" >/dev/null
      then return 4
      elif ((version > 16))
      then return 5
      fi
      
      mapfile -t
      local p
      local -a bytes
      bytes=($(
        for p in ${MAPFILE[@]}
        do echo $p
        done |
        convertbits 5 8 0
      )) || return 6
      if
	((
	  ${#bytes[@]} == 0 ||
	  ${#bytes[@]} <  2 ||
	  ${#bytes[@]} > 40
	))
      then return 7
      elif ((
	 version == 0 &&
	 ${#bytes[@]} != 20 &&
	 ${#bytes[@]} != 32
      ))
      then return 8
      else
	echo $hrp
	echo $version
	printf "%02x" "${bytes[@]}"
	echo
      fi
    }
  fi
}

segwitAddress() {
  local OPTIND OPTARG o
  if getopts hp:tv: o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} [-t] [-v witness-version] WITNESS_PROGRAM
	${FUNCNAME[0]} [-t] -p compressed-point
	END_USAGE
        ;;
      p)
        if [[ "$OPTARG" =~ ^0[23][[:xdigit:]]{64}$ ]]
        then ${FUNCNAME[0]} "$@" "$(
          xxd -p -r <<<"$OPTARG" |
          openssl dgst -sha256 -binary |
          openssl dgst -rmd160 -binary |
          xxd -p -c 20
        )"
        else echo "-p option expects a compressed point as argument" >&2
          return 1
        fi
        ;;
      t) HRP=tb ${FUNCNAME[0]} "$@" ;;
      v) WITNESS_VERSION=$OPTARG ${FUNCNAME[0]} "$@" ;;
    esac
  elif
    local hrp="${HRP:-bc}"
    [[ ! "$hrp"     =~ ^(bc|tb)$ ]]
  then return 1
  elif
    local witness_program="$1"
    [[ ! "$witness_program" =~ ^([[:xdigit:]]{2})+$ ]]
  then return 2
  elif
    local -i version=${WITNESS_VERSION:-0}
    ((version < 0))
  then return 3
  elif ((version == 0))
  then
    if [[ "$witness_program" =~ ^(.{40}|.{64})$ ]] # 20 or 32 bytes
    then
      # P2WPKH or P2WSH
      bech32_encode "$hrp" $(
	echo $version;
        echo -n "$witness_program" |
	while read -n 2; do echo 0x$REPLY; done |
        convertbits 8 5
      )
    else
       1>&2 echo For version 0, the witness program must be either 20 or 32 bytes long.
       return 4
    fi
  elif ((version <= 16))
  then
    bech32_encode -m "$hrp" $(
      echo $version
      echo -n "$witness_program" |
      while read -n 2; do echo 0x$REPLY; done |
      convertbits 8 5
     )
  else return 255
  fi
}

