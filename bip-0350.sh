#!/usr/env/bin bash

. bech32m.sh

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

convertbits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  local -i maxv=$(((1 << outbits) - 1))
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

segwit_encode()
  if
    local OPTIND OPTARG o
    getopts v: o
  then
    shift $((OPTIND - 1))
    SEGWIT_VERSION=$OPTARG $FUNCNAME "$@"
  else
    local hrp="$1" bech32opt
    local -i version="${SEGWIT_VERSION:-0}" 

    if (( version > 0 ))
    then bech32opt=-m
    fi

    bech32_encode $bech32opt "$hrp" $version $(convertbits 8 5 1)
  fi
