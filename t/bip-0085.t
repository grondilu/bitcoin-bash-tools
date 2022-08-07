#!/usr/bin/env bash

. bitcoin.sh

rootxprv=xprv9s21ZrQH143K2LBWUUQRFXhucrQqBpKdRRxNVq2zBqsx8HVqFk2uYo8kmbaLLHRdqtQpUm98uKfu3vca1LqdGhUtyoFnCNkfmXRyPXLjbKb

echo 1..$(grep -c "^if " ${BASH_SOURCE[0]})

base58 -d <<<"$rootxprv" |
bip85 0 |
if 
  xxd -p -c 64 |
  grep -q "^efecfbccffea313214232d29e71563d941229afb4338c21f9517c41aaa0d16f00b83d2a09ef747e7a64e8e2bd5a14869e693da66ce94ac2da570ab7ee48618f7$"
then echo "ok - test case 1, correct derived entropy"
else echo "not ok - test case 1, wrong derived entropy"
fi

base58 -d <<<"$rootxprv" |
bip85 0 1 |
if 
  xxd -p -c 64 |
  grep -q "^70c6e3e8ebee8dc4c0dbba66076819bb8c09672527c4277ca8729532ad711872218f826919f6b67218adde99018a6df9095ab2b58d803b5b93ec9802085a690e$"
then echo "ok - test case 2, correct derived entropy"
else echo "not ok - test case 2, wrong derived entropy"
fi

base58 -d <<<"$rootxprv" |
LANG=en bip85 mnemo 12 2>/dev/null |
if grep -q "girl mad pet galaxy egg matter matrix prison refuse sense ordinary nose"
then echo "ok - good 12 english words mnemonic"
else echo "not ok - wrong 12 english words mnemonic"
fi

base58 -d <<<"$rootxprv" |
LANG=en bip85 mnemo 18 2>/dev/null |
if grep -q "near account window bike charge season chef number sketch tomorrow excuse sniff circle vital hockey outdoor supply token"
then echo "ok - good 18 english words mnemonic"
else echo "not ok - wrong 18 english words mnemonic"
fi

base58 -d <<<"$rootxprv" |
LANG=en bip85 mnemo 24 2>/dev/null |
if grep -q "puppy ocean match cereal symbol another shed magic wrap hammer bulb intact gadget divorce twin tonight reason outdoor destroy simple truth cigar social volcano"
then echo "ok - good 24 english words mnemonic"
else echo "not ok - wrong 24 english words mnemonic"
fi

base58 -d <<<"$rootxprv" |
bip85 wif 2>/dev/null |
if grep -q Kzyv4uF39d4Jrw2W7UryTHwZr1zQVNk4dAFyqE6BuMrMh1Za7uhp
then echo "ok - good WIF"
else echo "not ok - wrong WIF"
fi

base58 -d <<<"$rootxprv" |
bip85 xprv |
base58 -c |
if grep -q xprv9s21ZrQH143K2srSbCSg4m4kLvPMzcWydgmKEnMmoZUurYuBuYG46c6P71UGXMzmriLzCCBvKQWBUv3vPB3m1SATMhp3uEjXHJ42jFg7myX
then echo "ok - good xprv"
else echo "not ok - wrong xprv"
fi

