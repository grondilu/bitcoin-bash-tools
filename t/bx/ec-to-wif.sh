#!/usr/bin/env bash

. bx.sh

declare -i n=0

echo 1..4

((n++))
if bx ec-to-wif 8ed1d17dabce1fccbbe5e9bf008b318334e5bcc78eb9e7c1ea850b7eb0ddb9c8 |
   grep -q L21LJEeJwK35wby1BeTjwWssrhrgQE2MZrpTm2zbMC677czAHHu3
then echo ok $n -
else echo not ok $n -
fi

((n++))
if bx ec-to-wif -u 8ed1d17dabce1fccbbe5e9bf008b318334e5bcc78eb9e7c1ea850b7eb0ddb9c8 |
   grep -q 5JuBiWpsjfXNxsWuc39KntBAiAiAP2bHtrMGaYGKCppq4MuVcQL
then echo ok $n -
else echo not ok $n -
fi

((n++))
if bx ec-to-wif -u 0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d |
   grep -q 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ
then echo ok $n -
else echo not ok $n -
fi

((n++))
if bx ec-to-wif -v 239 1560496d135730f5a1bb39580abba1fe8ea270768a08c49a66732772b0b811e2 |
   grep -q cNJFgo1driFnPcBdBX8BrJrpxchBWXwXCvNH5SoSkdcF6JXXwHMm
then echo ok $n -
else echo not ok $n -
fi
