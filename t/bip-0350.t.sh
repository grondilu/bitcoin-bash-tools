#!/usr/bin/env bash
#
# Translated from javascript :
# https://github.com/sipa/bech32/blob/master/ref/javascript/tests.js
#
# Original copyright notice and permission notice :
# 
#// Copyright (c) 2017, 2021 Pieter Wuille
#//
#// Permission is hereby granted, free of charge, to any person obtaining a copy
#// of this software and associated documentation files (the "Software"), to deal
#// in the Software without restriction, including without limitation the rights
#// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#// copies of the Software, and to permit persons to whom the Software is
#// furnished to do so, subject to the following conditions:
#//
#// The above copyright notice and this permission notice shall be included in
#// all copies or substantial portions of the Software.
#//
#// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#// THE SOFTWARE.


. bech32m.sh


declare -a valid_checksum_bech32=(
  A12UEL5L
  a12uel5l
  an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs
  abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw
  11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j
  split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w
  ?1ezyfcl
)

declare -a valid_checksum_bech32m=(
  A1LQFN3A
  a1lqfn3a
  an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6
  abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx
  11llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllludsr8
  split1checkupstagehandshakeupstreamerranterredcaperredlc445v
  ?1v759aa
)

declare -a invalid_checksum_bech32=(
  " 1nwldj5"
  $'\x7f1axkwrx'
  $'\x801eym55h'
  an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx
  pzry9x0s0muk
  1pzry9x0s0muk
  x1b4n0q5v
  li1dgmt3
  $'de1lg7wt\xff'
  A1G7SGD8
  10a06t8
  1qzzfhee
)

declare -a invalid_checksum_bech32m=(
  ' 1xj0phk'
  $'\x7F1g6xzxy'
  $'\x801vctc34'
  an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4
  qyrz8wqd2c9m
  1qyrz8wqd2c9m
  y1b0jsk6g
  lt1igcx5c0
  in1muywd
  mm1crxm3i
  au1s5cgom
  M1VUXWEZ
  16plkw9
  1p2gdwpf
)

declare -A valid_address=(
  [BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4]=0014751e76e8199196d454941c45d1b3a323f1433bd6
  [tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7]=00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262
  [bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y]=5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6
  [BC1SW50QGDZ25J]=6002751e
  [bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs]=5210751e76e8199196d454941c45d1b3a323
  [tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy]=0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433
  [tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c]=5120000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433
  [bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0]=512079be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
)

declare -a invalid_address=(
  tc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq5zuyut
  bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqh2y7hd
  tb1z0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqglt7rf
  BC1S0XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ54WELL
  bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kemeawh
  tb1q0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq24jc47
  bc1p38j9r5y49hruaue7wxjce0updqjuyyx0kh56v8s25huc6995vvpql3jow4
  BC130XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ7ZWS8R
  bc1pw5dgrnzv
  bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v8n0nx0muaewav253zgeav
  BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P
  tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq47Zagq
  bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v07qwwzcrf
  tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vpggkg4j
  bc1gmk9yu
)

declare -i n=0
declare t

for t in "${valid_checksum_bech32[@]}"
do
  ((n++))
  if bech32_decode "$t" >/dev/null
  then echo "ok $n - $t"
  else echo "not ok $n - unexpected invalid test for $t"
  fi
done

for t in "${valid_checksum_bech32m[@]}"
do
  ((n++))
  if bech32_decode -m "$t" >/dev/null
  then echo "ok $n - $t"
  else echo "not ok $n - unexpected invalid test for $t"
  fi
done

for t in "${invalid_checksum_bech32[@]}"
do
  ((n++))
  if bech32_decode "$t" >/dev/null
  then echo "not ok $n - unexpected valid test for $t"
  else echo "ok $n - $t => $?"
  fi
done

for t in "${invalid_checksum_bech32m[@]}"
do
  ((n++))
  if bech32_decode -m "$t" >/dev/null
  then echo "not ok $n - unexpected valid test for $t"
  else echo "ok $n - $t => $?"
  fi
done

. bip-0350.sh

for address in "${!valid_address[@]}"
do
  scriptpubkey=${valid_address[$address]}
  hrp="${address%1*}" payload="${address##*1}" 

  if segwit_decode "$address" >/dev/null
  then segwit_decode "$address" |
    {
      ((n++))
      declare hrp program output recreated_address
      declare -i version=0 encodedversion
      read hrp
      read version
      encodedversion=$version
      (( version > 0 && (encodedversion+=0x50) ))
      read program
      printf -v output "%02x%02x%s" $encodedversion $((${#program}/2)) $program
      if [[ "$output" = "$scriptpubkey" ]]
      then echo "ok $n - $address -> $scriptpubkey"
      else echo "not ok $n - $address -> $output instead of $scriptpubkey"
      fi

      ((n++))
      recreated_address="$(
	echo -n $program |
	while read -n 2; do echo $((0x$REPLY)); done |
	segwit_encode -v $version "$hrp"
      )"
      if [[ "$recreated_address" = "${address,,}" ]]
      then echo "ok $n - could recreate $address"
      else echo "not ok $n - failed to recreate $address, got $recreated_address instead"
      fi
    }  
  else echo "failed to decode $address"
  fi
done

for address in "${invalid_address[@]}"
do
  segwit_decode $address >/dev/null;
  declare -i error=$?
  ((n++))
  if ((error > 0))
  then echo "ok $n - got error code $error for $address"
  else echo "not ok $n - failed to detect error for $address"
  fi
done
