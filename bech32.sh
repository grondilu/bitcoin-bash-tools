#!/usr/env/bin bash

# Translated from javascript.
#
# Original code link:
# https://github.com/sipa/bech32/blob/master/ref/javascript/bech32.js

# Copyright and permission notice in original file :
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

readonly bech32_sh
declare bech32_charset="qpzry9x8gf2tvdw0s3jn54khce6mua7l"
declare -A bech32_charset_reverse
for i in {0..31}
do bech32_charset_reverse[${bech32_charset:$i:1}]=$((i))
done


BECH32_CONST=1

bech32()
  if local OPTIND OPTARG o
    getopts hmv: o
  then shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-EOF
	usage:
	  ${FUNCNAME[0]} -h
	  ${FUNCNAME[0]} [-m] hrp data
	EOF
      ;;
      m) BECH32_CONST=0x2bc830a3 ${FUNCNAME[0]} "$@" ;;
      v)
	if [[ "$OPTARG" =~ ^(.{1,83})1([$bech32_charset]{6,})$ ]]
        then
          ${FUNCNAME[0]} "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]::-6}" |
          grep -q "^$OPTARG$"
        else return 33
        fi
      ;;
    esac
  elif [[ "$1$2" =~ [A-Z] && "$hrp$data" =~ [a-z] ]]
  then return 1
  elif local hrp="${1,,}" data="${2,,}"
    (( ${#hrp} + ${#data} + 6 > 90 ))
  then return 2
  elif (( ${#hrp} < 1 || ${#hrp} > 83 ))
  then return 3
  elif 
    local -i ord p out_of_range=0
    for ((p=0;p<${#hrp};p++))
    do
      printf -v ord "%d" "'${hrp:$p:1}"
      if ((ord < 33 || ord > 126))
      then out_of_range=1; break
      fi
    done
    ((out_of_range == 1))
  then return 4
  elif [[ "$data" =~ [^$bech32_charset] ]]
  then return 5
  else
    echo "${hrp}1$data$(
      bech32_create_checksum "$hrp" $(
        echo -n "$data" |
        while read -n 1; do echo "${bech32_charset_reverse[$REPLY]}"; done
      ) | while read; do echo -n "${bech32_charset:$REPLY:1}"; done
    )"
  fi

polymod() {
  local -ai generator=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  local -i chk=1 value
  for value
  do
    local -i top i
    
    ((top = chk >> 25, chk = (chk & 0x1ffffff) << 5 ^ value))
    
    for i in 0 1 2 3 4
    do (( ((top >> i) & 1) && (chk^=${generator[i]}) ))
    done
  done
  echo $chk
}

hrpExpand() {
  local -i p ord
  for ((p=0; p < ${#1}; ++p))
  do printf -v ord "%d" "'${1:$p:1}"
    echo $(( ord >> 5 ))
  done
  echo 0
  for ((p=0; p < ${#1}; ++p))
  do printf -v ord "%d" "'${1:$p:1}"
    echo $(( ord & 31 ))
  done
}

verifyChecksum() {
  local hrp="$1"
  shift
  local -i pmod="$(polymod $(hrpExpand "$hrp") "$@")"
  (( pmod == $BECH32_CONST ))
}

bech32_create_checksum() {
  local hrp="$1"
  shift
  local -i p mod=$(($(polymod $(hrpExpand "$hrp") "$@" 0 0 0 0 0 0) ^ $BECH32_CONST))
  for p in 0 1 2 3 4 5
  do echo $(( (mod >> 5 * (5 - p)) & 31 ))
  done
}

bech32_encode()
  if
    local OPTIND o
    getopts m o
  then
    shift $((OPTIND - 1))
    BECH32_CONST=0x2bc830a3 $FUNCNAME "$@"
  else
    local hrp=$1 i
    shift
    echo -n "${hrp}1"
    {
      for i; do echo $i; done
      bech32_create_checksum "$hrp" "$@"
    } |
    while read; do echo -n ${bech32_charset:$REPLY:1}; done
    echo
  fi

bech32_decode()
  if
    local OPTIND o
    getopts m o
  then
    shift $((OPTIND - 1))
    BECH32_CONST=0x2bc830a3 $FUNCNAME "$@"
  else
    local bechString=$1
    local -i p has_lower=0 has_upper=0 ord

    for ((p=0;p<${#bechString};++p))
    do
      printf -v ord "%d" "'${bechString:$p:1}"
      if   ((ord <  33 || ord >  126))
      then return 1
      elif ((ord >= 97 && ord <= 122))
      then has_lower=1
      elif ((ord >= 65 && ord <= 90))
      then has_upper=1
      fi
    done
    if ((has_upper && has_lower))
    then return 2 # mixed case
    elif bechString="${bechString,,}"
      ((${#bechString} > 90))
    then return 3 # string is too long
    elif [[ ! "$bechString" =~ 1 ]]
    then return 4 # no separator
    elif
      local hrp="${bechString%1*}"
      test -z $hrp
    then return 5 # no human readable part
    elif local data="${bechString##*1}"
      ((${#data} < 6))
    then return 6 # data is too short
    else
      for ((p=0;p<${#data};++p))
      do echo "${bech32_charset_reverse[${data:$p:1}]}"
      done |
      {
	mapfile -t
	if verifyChecksum "$hrp" "${MAPFILE[@]}"
	then
	  echo $hrp
	  for p in "${MAPFILE[@]::${#MAPFILE[@]}-6}"
	  do echo $p
	  done
	else return 8
	fi
      }
    fi
  fi
