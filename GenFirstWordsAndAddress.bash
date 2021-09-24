#!/bin/bash
#GenFirstWordsAndAddress.bash
#CREDIT: https://github.com/grondilu/bitcoin-bash-tools Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
#This script: github:petjal Thu Sep 23 14:59:23 UTC 2021
#VERSION: 2109240339Z
#TODO: test entropy
#TODO: trap errors, bail on everything
#TODO: insert all external code into this file
#TODO: sign this file when done
#TODO: test on windows linux terminal, macos
#TODO: move this to github - done 2109240339Z https://github.com/petjal/bitcoin-bash-tools/blob/pjdev/GenFirstWordsAndAddress.bash

#USAGE:
#For use by technical folks to help beginners among family, friends, confidants get started safely as simply as possible
#Open a terminal on gnu/linux. (Not yet tested on windows, mac. Developed initially on chromebook in termux).
#Get signed file bundle. 
#Check bundle signature.
#Extract signed file bundle.
#Run:  cd ./bitcoin-bash-tools
#Run:  bash GenSimplestAddress.bash

echo
echo "1.: Generating your secret seed phrase..."
echo "Below, in Step 2., is an ordered sequence list of 12 words. They are your \"secret seed phrase\"."
echo "1a.: Respect them.  These words, _in this order_, _are_ your bitcoin."
echo "(This secret seed phrase can be used by you anytime later to generate your private bitcoin keys. \"Not your keys, not your coin.\")"
echo "1b.: Do not lose them. Without this sequence of 12 words, you have lost all your bitcoin."
echo "1c.: Do not share them. Do not let anyone see them whom you do not trust with your largest bank account. With them, anyone can steal your bitcoin from you."
echo "1d.: Bequeath them.  Make them part of your succession plan (your last will and testament) to pass them, and thus your bitcoin, on to your heirs."
echo "1e.: Back them up. Keep them where you keep your most valuable documents; a safe or safe deposit box is good; a good password manager is good (consider bitwarden, keepass). Text them to yourself with Signal or Element app."
echo "1f.: Memorize them.  Best is to memorize them, and refresh your memory every week or so."
echo "A few good memorization techniques:"
echo "    https://en.wikipedia.org/wiki/Mnemonic_major_system"
echo "    https://en.wikipedia.org/wiki/Mnemonic_peg_system"
echo "    https://en.wikipedia.org/wiki/Method_of_loci"
echo "    https://en.wikipedia.org/wiki/Active_recall"
echo "    https://en.wikipedia.org/wiki/Spaced_repetition"
#CREDIT: last two:  https://twitter.com/search?q=%40KetoCarnivore%20anki&src=typed_query&f=top


#Load bitcoin functions into shell.
. ./bitcoin.sh
. ./bip-0039.sh
. ./bip-0032.sh
. ./bip-0173.sh
#generate some entropy, by forcing some disk activity, for the openssl random number generator.... 
find ~ -type f 2> /dev/null | head -n 10000 | xargs cat > /dev/null 2>&1
echo
#echo "generating new sequence of 12 secret words..."
my_new_secret_words=$(create-mnemonic 128)  # 128 = 12 words, 256 = 24 words of entropy
#echo "my_new_secret_words (create-mnemonic 128):"
echo "2. Your secret seed phrase:"
echo $my_new_secret_words
echo
#echo generating 512 bit root seed via pbkdf sha512, no password, 2048 iterations...takes a minute or so
#time root_seed=$(bip39 $my_secret_words)
#root_seed=$(bip39 $my_new_secret_words)
echo "(This next step will take up to about a minute for enhanced security...)"
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
echo "3. CONGRATULATIONS!  Here is your public bitcoin address! You can share this with others."
segwitAddress -p $p
echo
echo "4. Buy bitcoin.  Sign up on an exchange to buy bitcoin every week or so (dollar-cost averaging, \"stacking sats\"). Consider swanbitcoin.com, pro.coinbase.com (\"pro\" is cheaper than regular coinbase.com)."
echo
echo "5. Possess your bitcoin.  Arrange for the exchange to automatically withdraw or send your bitcoin to your public bitcoin address, as much as possible, as often as possible, as soon as possible. Not your key, not your coin.  You really don't own your bitcoin until they have been sent by the exchange to your public address which is protected by your private seed phrase (and thus your private key)."
echo
echo "6. Study bitcoin. It is changing the world as we speak.  Learn as much about bitcoin as you can, as fast as you can.  Improve your bitcoin security over time."
echo
