#!/usr/bin/env bash

. bitcoin.sh

rootxprv=xprv9s21ZrQH143K2LBWUUQRFXhucrQqBpKdRRxNVq2zBqsx8HVqFk2uYo8kmbaLLHRdqtQpUm98uKfu3vca1LqdGhUtyoFnCNkfmXRyPXLjbKb

echo 1..$(grep -c "^if " ${BASH_SOURCE[0]})

base58 -d <<<"$rootxprv" |
bip85 0 |
if 
  basenc --base16 -w128 |
  grep -q "^EFECFBCCFFEA313214232D29E71563D941229AFB4338C21F9517C41AAA0D16F00B83D2A09EF747E7A64E8E2BD5A14869E693DA66CE94AC2DA570AB7EE48618F7$"
then echo "ok - test case 1, correct derived entropy"
else echo "not ok - test case 1, wrong derived entropy"
fi

base58 -d <<<"$rootxprv" |
bip85 0 1 |
if 
  basenc --base16 -w128 |
  grep -q "^70C6E3E8EBEE8DC4C0DBBA66076819BB8C09672527C4277CA8729532AD711872218F826919F6B67218ADDE99018A6DF9095AB2B58D803B5B93EC9802085A690E$"
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

base58 -d <<<"$rootxprv" |
bip85 hex 64 |
if grep -qi '^492db4698cf3b73a5a24998aa3e9d7fa96275d85724a91e71aa2d645442f878555d078fd1f1f67e368976f04137b1f7a0d19232136ca50c44614af72b5582a5c$'
then echo "ok - good hex"
else echo "not ok - wrong hex"
fi


# vi: ft=bash
