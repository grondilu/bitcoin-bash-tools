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

declare BECH32_CHARSET="qpzry9x8gf2tvdw0s3jn54khce6mua7l"
declare -A BECH32_CHARSET_REVERSE
for i in {0..31}
do BECH32_CHARSET_REVERSE[${BECH32_CHARSET:$i:1}]=$((i))
done

declare -ai generator=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)

declare -A encodings=(BECH32 bech32 BECH32M bech32m)

getEncodingConst()
  if [[ "$1" = "${encodings[BECH32]}" ]]
  then echo 1
  elif [[ "$1" = "${encodings[BECH32M]}" ]]
  then echo 0x2bc830a3
  else return 1
  fi

polymod() {
  local -i chk=1
  while read
  do
    local -i value=REPLY top i
    
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
  local hrp="$1" enc="$2"
  local -i pmod=$({ hrpExpand "$hrp"; cat; }|polymod) encconst=$(getEncodingConst "$enc")
  (( pmod == encconst ))
}

createChecksum() {
  {
    local -i i
    hrpExpand $1
    cat
    for i in {1..6}; do echo 0; done
  } | 
  {
    local -i p mod=$(($(polymod) ^ $(getEncodingConst $2)))
    for p in 0 1 2 3 4 5
    do echo $(( (mod >> 5 * (5 - p)) & 31 ))
    done
  }
}

bech32m_encode() {
  local hrp=$1 enc=$2 data="$(mktemp)"
  echo -n "${hrp}1"
  cat > $data
  cat $data <(createChecksum $hrp $enc < $data) |
  while read; do echo -n ${BECH32_CHARSET:$REPLY:1}; done
  rm $data
}

bech32m_decode() {
  local bechString=$1 enc=$2
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
  then return 2
  elif bechString="${bechString,,}"
    ((${#bechString} > 90))
  then return 3
  elif 
    [[ ! "$bechString" =~ 1 ]]
  then return 4
  elif
    local hrp="${bechString%1*}"
    test -z $hrp
  then return 5
  elif local data="${bechString##*1}"
    ((${#data} < 6))
  then return 6
  else
    echo $hrp
    local tmpfile="$(mktemp)"
    for ((p=0;p<${#data};++p))
    do echo "${BECH32_CHARSET_REVERSE[${data:$p:1}]}"
    done > $tmpfile
    if grep -q '^$' $tmpfile
    then rm $tmpfile; return 7
    elif verifyChecksum "$hrp" "$enc" < $tmpfile
    then
      cat $tmpfile
      rm $tmpfile
    else
      rm $tmpfile
      return 8
    fi
fi
}
