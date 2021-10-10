#!/usr/bin/env bash

LANG=C
PBKDF2_METHOD=python
. bitcoin.sh

declare -i n=0

mnemonic=(abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about)

seed="$(mktemp)"
mnemonic-to-seed ${mnemonic[@]} > "$seed"

rootpriv=zprvAWgYBBk7JR8Gjrh4UJQ2uJdG1r3WNRRfURiABBE3RvMXYSrRJL62XuezvGdPvG6GFBZduosCc1YP5wixPox7zhZLfiUm8aunE96BBa4Kei5
rootpub=zpub6jftahH18ngZxLmXaKw3GSZzZsszmt9WqedkyZdezFtWRFBZqsQH5hyUmb4pCEeZGmVfQuP5bedXTB8is6fTv19U1GQRyQUKQGUTzyHACMF

((n++))
if diff <(bip84 -s    < "$seed") <(base58 -d <<<"$rootpriv"|head -c -4)
then echo "ok $n"
else echo "not ok $n"
fi
((n++))
if diff <(bip84 -s /N < "$seed") <(base58 -d <<<"$rootpub"|head -c -4)
then echo "ok $n"
else echo "not ok $n"
fi

# Account 0, root=m/84'/0'/0'
xpriv=zprvAdG4iTXWBoARxkkzNpNh8r6Qag3irQB8PzEMkAFeTRXxHpbF9z4QgEvBRmfvqWvGp42t42nvgGpNgYSJA9iefm1yYNZKEm7z6qUWCroSQnE
xpub=zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs
((n++))
if diff <(bip84 -s m/84h/0h/0h < "$seed") <(base58 -d <<<"$xpriv"|head -c -4)
then echo "ok $n"
else echo "not ok $n"
fi
((n++))
if diff <(bip84 -s m/84h/0h/0h/N < "$seed") <(base58 -d <<<"$xpub"|head -c -4)
then echo "ok $n"
else echo "not ok $n"
fi

# Account 0, first receiving address=m/84'/0'/0'/0/0
privkey=KyZpNDKnfs94vbrwhJneDi77V6jF64PWPF8x5cdJb8ifgg2DUc9d
pubkey=0330d54fd0dd420a6e5f8d3624f5f3482cae350f79d5f0753bf5beef9c2d91af3c
address=bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu

path="m/84h/0h/0h/0/0"
((n++))
if [[ "$(bip84 -s "$path" < "$seed" |tail -c 32 |wif)" = "$privkey" ]]
then echo "ok $n"
else echo "not ok $n"
fi

((n++))
if diff <(bip84 -s "$path/N" < "$seed" |tail -c 33) <(xxd -p -r <<<"$pubkey")
then echo "ok $n"
else echo "not ok $n"
fi

((n++))
if bitcoinAddress "$(bip84 -s "$path/N" < "$seed" |base58 -c)" |grep -q "^$address$"
then echo "ok $n"
else echo "not ok $n"
fi

path="m/84h/0h/0h/0/1"
# Account 0, second receiving address=m/84'/0'/0'/0/1
privkey=Kxpf5b8p3qX56DKEe5NqWbNUP9MnqoRFzZwHRtsFqhzuvUJsYZCy
pubkey=03e775fd51f0dfb8cd865d9ff1cca2a158cf651fe997fdc9fee9c1d3b5e995ea77
address=bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g
((n++))
if [[ "$(bip84 -s "$path" < "$seed" |tail -c 32 |wif)" = "$privkey" ]]
then echo "ok $n"
else echo "not ok $n"
fi

((n++))
if diff <(bip84 -s "$path/N" < "$seed" |tail -c 33) <(xxd -p -r <<<"$pubkey")
then echo "ok $n"
else echo "not ok $n"
fi

((n++))
if bitcoinAddress "$(bip84 -s "$path/N" < "$seed" |base58 -c)" |grep -q "^$address$"
then echo "ok $n"
else echo "not ok $n"
fi

path="m/84h/0h/0h/1/0"
# Account 0, first change address=m/84'/0'/0'/1/0
privkey=KxuoxufJL5csa1Wieb2kp29VNdn92Us8CoaUG3aGtPtcF3AzeXvF
pubkey=03025324888e429ab8e3dbaf1f7802648b9cd01e9b418485c5fa4c1b9b5700e1a6
address=bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el
((n++))
if [[ "$(bip84 -s "$path" < "$seed" |tail -c 32 |wif)" = "$privkey" ]]
then echo "ok $n"
else echo "not ok $n"
fi

((n++))
if diff <(bip84 -s "$path/N" < "$seed" |tail -c 33) <(xxd -p -r <<<"$pubkey")
then echo "ok $n"
else echo "not ok $n"
fi

((n++))
if bitcoinAddress "$(bip84 -s "$path/N" < "$seed" |base58 -c)" |grep -q "^$address$"
then echo "ok $n"
else echo "not ok $n"
fi

rm "$seed"
