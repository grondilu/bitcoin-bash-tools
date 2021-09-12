#!/usr/bin/env bash

. bech32m.sh

declare -i t

echo 1..$(grep -c ^_ $BASH_SOURCE)

function _is_valid {
  if
    ((t++))
    bech32m_decode "$1" bech32m >/dev/null
  then echo "ok $t - $1 is valid"
  else echo "not ok $t - false negative for $1"
  fi
}

function _is_not_valid {
  if
    ((t++))
    bech32m_decode "$1" bech32m >/dev/null
  then echo "not ok $t - false positive for $1"
  else echo "ok $t - $1 is invalid as expected (error code $?)"
  fi
}
 
_is_valid "A1LQFN3A"
_is_valid "a1lqfn3a"
_is_valid "an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6"
_is_valid "abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx"
_is_valid "11llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllludsr8"
_is_valid "split1checkupstagehandshakeupstreamerranterredcaperredlc445v"
_is_valid "?1v759aa"

_is_not_valid $'\x20'1xj0phk
_is_not_valid $'\x7F'1g6xzxy
_is_not_valid $'\x80'1vctc34
_is_not_valid "an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4"
_is_not_valid "qyrz8wqd2c9m"
_is_not_valid "1qyrz8wqd2c9m"
_is_not_valid "y1b0jsk6g"
_is_not_valid "lt1igcx5c0"
_is_not_valid "in1muywd"
_is_not_valid "mm1crxm3i"
_is_not_valid "au1s5cgom"
_is_not_valid "M1VUXWEZ"
_is_not_valid "16plkw9"
_is_not_valid "1p2gdwpf"
