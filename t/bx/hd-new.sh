#!/usr/bin/env bash

. bx.sh

declare -i n=0

echo 1..4

((n++))
if bx hd-new 000102030405060708090a0b0c0d0e0f |
   grep -q xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi
then echo ok $n
else echo not ok $n
fi

((n++))
if bx hd-new fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542 |
  grep -q xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
then echo ok $n
else echo not ok $n
fi

((n++))
if bx hd-new baadf00dbaadf00d 2>/dev/null
then echo not ok $n - an error was expected
else echo ok $n
fi

((n++))
if bx hd-new -v 70615956 baadf00dbaadf00dbaadf00dbaadf00d |
  grep -q tpubD6NzVbkrYhZ4XbUpwb3JpXFpXXa8CrP8cTkqzrnsnPV6Z1v3C15HRcUquADA8CMEawvRMMGoKnwg8fza8pPdFUcJH6uxZJJKkDYJJAGT53e
then echo ok $n
else echo "not ok $n - # SKIP https://github.com/libbitcoin/libbitcoin-explorer/issues/694"
fi
