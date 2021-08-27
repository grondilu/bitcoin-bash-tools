#!/usr/bin/env bash

. secp256k1.sh
echo 1..10

let -i a b t=0
for i in {1..10}
do
  ((a=RANDOM, b=RANDOM, t++))
  if [[ "$({ secp256k1 $a; secp256k1 $b; } |secp256k1)" = "$(secp256k1 $((a+b)))" ]]
  then echo "ok $t - $a*G + $b*G = ($a+$b)*G"
  else echo "not ok $t - $a*G + $b*G != ($a+$b)*G"
  fi
done
