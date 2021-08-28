#!/usr/bin/env bash

. bip-0032.sh

echo 1..1

declare -i t=0
jq -r '.[]|[.seed,.m."ext prv"]|join(" ")' t/bip-0032.t.json |
{
  while read seed xprv
  do 
    ((t++))
    declare result="$(echo -n "$seed" |xxd -p -r |bip32 m)"
    if [[ "$result" = "$xprv" ]]
    then echo "ok $t - $seed → ${xprv::10}...${xprv: -10}"
    else echo "not ok $t - seed $seed, $xpriv expected, got $result"
    fi
  done
}
