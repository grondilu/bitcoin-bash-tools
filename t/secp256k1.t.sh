#!/usr/bin/env bash

. secp256k1.sh
echo 1..11

let -i a b t=0
for i in {1..10}
do
  ((a=RANDOM, b=RANDOM, t++))
  if [[ "$({ secp256k1 $a; secp256k1 $b; } |secp256k1)" = "$(secp256k1 $((a+b)))" ]]
  then echo "ok $t - $a*G + $b*G = ($a+$b)*G"
  else echo "not ok $t - $a*G + $b*G != ($a+$b)*G"
  fi
done

((t++))
n="0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141"
if [[ "$(secp256k1 10 $n)" = '0xA' ]]
then echo "ok $t - 10 + n = 10"
else echo "not ok $t - 10 + n != 10"
fi
