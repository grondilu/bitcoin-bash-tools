#!/usr/bin/env bash

. bx.sh

echo 1..2

declare -i n=0

((n++))
if bx ec-to-public 8ed1d17dabce1fccbbe5e9bf008b318334e5bcc78eb9e7c1ea850b7eb0ddb9c8 |
   grep -q 0247140d2811498679fe9a0467a75ac7aa581476c102d27377bc0232635af8ad36
then echo ok $n -
else echo not ok $n - unexpected pubkey for 8ed1d17dabce1fccbbe5e9bf008b318334e5bcc78eb9e7c1ea850b7eb0ddb9c8
fi

((n++))
if bx ec-to-public -u 8ed1d17dabce1fccbbe5e9bf008b318334e5bcc78eb9e7c1ea850b7eb0ddb9c8 |
   grep -q 0447140d2811498679fe9a0467a75ac7aa581476c102d27377bc0232635af8ad36e87bb04f401be3b770a0f3e2267a6c3b14a3074f6b5ce4419f1fcdc1ca4b1cb6
then echo ok $n -
else echo not ok $n - unexpected uncompressed pubkey for 8ed1d17dabce1fccbbe5e9bf008b318334e5bcc78eb9e7c1ea850b7eb0ddb9c8
fi
