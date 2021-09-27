#!/bin/bash
#GenFirstWordsAndAddress.bash
#CREDIT: https://github.com/grondilu/bitcoin-bash-tools Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
#LICENSE: SPDX MIT https://spdx.org/licenses/MIT.html
#SUPPORT: https://github.com/petjal/bitcoin-bash-tools/issues
#This script: github:petjal Thu Sep 23 14:59:23 UTC 2021
#VERSION: 2109270608Z
#CHANGE: pj add license, support, tweak text a lot, reduce entropy find head
#TODO: test entropy - done 2109240526Z
#TODO: trap errors, bail on everything
#TODO: insert all external code into this file
#TODO: sign this file when done
#TODO: test on windows linux (wsl) terminal, macos
#TODO: move this to github - done 2109240339Z https://github.com/petjal/bitcoin-bash-tools/blob/pjdev/GenFirstWordsAndAddress.bash
#TODO: create github action to test script - done 2109240427Z
 
#USAGE:
#For use by technical folks to help beginners among family, friends, confidants get started safely as simply as possible
#Open a terminal on gnu/linux. (Not yet tested on windows, mac. Developed initially on chromebook in termux).
#Get signed file bundle. 
#Check bundle signature.
#Extract signed file bundle.
#Run:  cd ./bitcoin-bash-tools
#Run:  bash GenSimplestAddress.bash

#REQUIREMENTS: Install dc, ent, openssl. 


echo
echo "This script will generate two important strings of characters."
echo "  The first is your bitcoin secret seed phrase."
echo "  The second is your public bitcoin address."
echo

#Load bitcoin functions into shell.
. ./bitcoin.sh
. ./bip-0039.sh
. ./bip-0032.sh
. ./bip-0173.sh

#ENTROPY
echo "But first, we need to generate and test your computer's entropy..."
echo "Entropy is a vital part of bitcoin cryptography.  It must be very, very good."
echo "This step may take a couple of minutes. This script will appear to hang, please be patient..."
#echo generating some entropy, by forcing some disk activity, for the openssl random number generator.... 
#This find command fails in github action workspace, that's ok.
#If you don't get enough entropy, increase this "head" count from 100 to 1000 or 10000, but the script will take that much longer.
find ~ -type f 2> /dev/null | head -n 100 | xargs cat > /dev/null 2>&1
#test entropy
kernel_entropy_avail=$(cat /proc/sys/kernel/random/entropy_avail) # less than 100-200, you have a problem
echo "kernel_entropy_avail: $kernel_entropy_avail (greater than 100 is good)"
if [[ "$kernel_entropy_avail" -lt "200" ]] ; then echo "ERROR: kernel entropy_avail $kernel_entropy_avail less than 100, too low, sorry, cannot proceed." ; exit 1 ; fi
#Entropy = 1.000000 bits per bit.
entropy_test_val=$(head -c 1M /dev/urandom > /tmp/out ;  ent -b /tmp/out | grep Entropy | cut -d ' ' -f 3)
echo "entropy test value: $entropy_test_val (1.000 is great)"
if [[ "$entropy_test_val" < "0.9000" ]] ; then echo "ERROR: entropy $entropy_test_val less than 0.9, too low, sorry, cannot proceed." ; fi
echo


#echo "generating new sequence of 12 secret words..."
my_new_secret_words=$(create-mnemonic 128)  # 128 = 12 words, 256 = 24 words of entropy
#echo "my_new_secret_words (create-mnemonic 128):"
echo "HERE IS YOUR BITCOIN SECRET SEED PHRASE:"
echo $my_new_secret_words
echo
echo "  Order matters. The sequence of the secret seed phrase words matters." 
#TODO:  does case matter?
echo "  Do not lose them. Without this sequence of 12 words, you have lost all your bitcoin. Keep them where you keep your most valuable documents; a safe or safe deposit box, a password manager (consider bitwarden, keepass)."
echo "  Do not share them. With them, anyone can steal your bitcoin."
echo "  Bequeath them.  Add them to your succession plan, your last will and testament, to pass them, and thus your bitcoin, on to your heirs."
echo "  Memorize them.  Best is to memorize them; add a weekly reminder to your calendar."
echo "    A few good memorization techniques:"
echo "      https://en.wikipedia.org/wiki/Mnemonic_major_system"
echo "      https://en.wikipedia.org/wiki/Mnemonic_peg_system"
echo "      https://en.wikipedia.org/wiki/Method_of_loci"
echo "      https://en.wikipedia.org/wiki/Active_recall"
echo "      https://en.wikipedia.org/wiki/Spaced_repetition"
#CREDIT: last two:  https://twitter.com/search?q=%40KetoCarnivore%20anki&src=typed_query&f=top



echo
echo "Buy bitcoin.  Sign up on a bitcoin exchange to buy bitcoin every week or so (dollar-cost averaging, \"stacking sats\"). Consider swanbitcoin.com, pro.coinbase.com (\"pro\" is cheaper than regular coinbase.com)."


echo
echo "This next step will take up to a minute or so..."
#echo generating 512 bit root seed via pbkdf sha512, no password, 2048 iterations...takes a minute or so
#time root_seed=$(bip39 $my_secret_words)
#root_seed=$(bip39 $my_new_secret_words)
root_seed=$(mnemonic-to-seed $my_new_secret_words 2> /dev/null)
#echo
#echo "root_seed (mnemonic-to-seed \$my_new_secret_words)":
#echo $root_seed
#echo
#echo "generating extended master private (m) and public (M) keys and master chain code (c)"
m=$(bip32 -s $root_seed)
#echo "extended master private key xprv (m) (bip32 -s \$root_seed):"
#echo "$m"
#echo "#####extended master private key details (bip32 -p \$m):"
private_key_details=$(bip32 -p $m)
#echo "$private_key_details" 
#echo "#####xprv in hex (base58 -x \$m):"
#echo "#####version (xpub/xprv)(4 bytes), depth(1), parent fingerprint(4), index(4), chain code(32), key(33), checksum(4); hex is 2 chars per byte"
#base58 -x $m # 0488ade40000000000000000009687afce7961c0a9e5846d13d9b513e8a176cfb0847e827ea3bff452582d2d3c007334230962d894257fd1fc598b2cf1f5758d0977b270782f6a217237315144d1287409a0
#echo
#echo "generate public key xpub (M) (bip32 \$m/N) (bip-0032.sh line 11):"
M=$(bip32 $m/N)
#echo $M
#echo "#####extended public key details (bip32 -p \$M):"
public_key_details=$(bip32 -p $M)
#echo "$public_key_details" 
#echo "#####xpub in hex (base58 -x \$M):"
#echo "#####version (xpub/xprv)(4 bytes), depth(1), parent fingerprint(4), index(4), chain code(32), key(33), checksum(4); hex is 2 chars per byte"
#base58 -x $M 
#echo "#####select public key \"point\" (p) (bip32 -p \$M | cut -f 6):"
p=$(echo $public_key_details | cut -d ' ' -f 6)
#echo $p
#echo
#echo "generate bech32 bc1 segwitAddress from public key \"point\" (segwitAddress -p <point>):"
echo


echo "Possess your bitcoin."
echo "Below is your PUBLIC BITCOIN ADDRESS.  Arrange for the bitcoin exchange to automatically withdraw or send your bitcoin to your PUBLIC BITCOIN ADDRESS, as much as possible, as often as possible, as soon as possible. Not your keys, not your coin. You really don't own your bitcoin until they have been sent by the exchange to your public address which is protected by your private seed phrase (and thus your private key)."
echo "HERE IS YOUR PUBLIC BITCOIN ADDRESS:"
segwitAddress -p $p
echo


echo "Study bitcoin. It is changing the world.  Learn about bitcoin as much as you can, as fast as you can.  Improve your bitcoin security over time."
echo
