#!/usr/bin/env bash

. bip-0039.sh

declare -i t=0

echo 1..$(grep -c '^_' "$BASH_SOURCE")

function _test() {
  ((t++))
  if pbkdf2 $1 | grep -q "$2"
  then echo ok $t
  else echo not ok $t
  fi
}

_test "sha1 password salt 1 20" "0c60c80f961f0e71f3a9b524af6012062fe037a6"
_test "sha1 password salt 2 20" "ea6c014dc72d6f8ccd1ed92ace1d41f0d8de8957"
_test "sha1 password salt 4096 20" "4b007901b765489abead49d926f721d065a429c1"
_test "sha1 passwordPASSWORDpassword saltSALTsaltSALTsaltSALTsaltSALTsalt 4096 25" "3d2eec4fe41c849b80c8d83662c0e44a8b291a964cf2f07038"

