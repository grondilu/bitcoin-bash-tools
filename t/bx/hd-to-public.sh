#!/usr/bin/env bash

. bx.sh

echo 1..6
declare -i n

((n++)) # Example 1
if bx hd-public -d xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8
then echo not ok $n - error was expected
else echo ok $n - BIP32 Test vector Chain m/0H, public derivation
fi

((n++)) # Example 2
if bx hd-public -i 1 xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw |
  grep -q xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ
then echo ok $n - BIP32 Test Vector 1 Chain m/0H/1, public derivation
else echo not ok $n - BIP32 Test Vector 1 Chain m/0H/1, public derivation
fi

((n++)) # Example 3
if bx hd-public -d -i 2 xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ
then echo not ok $n - error was expected
else echo ok $n - BIP32 Test Vector 1 Chain m/0H/1/2H, public derivation
fi

((n++)) # Example 4
if bx hd-public -d xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi |
  grep -q xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw
then echo ok $n - BIP32 Test Vector 1 Chain m/0H, private derivation
else echo not ok $n - BIP32 Test Vector 1 Chain m/0H, private derivation
fi

((n++)) # Example 5
if bx hd-public -i 1 xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7 |
  grep -q xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ
then echo ok $n - BIP32 Test Vector 1 Chain m/0H/1, private derivation
else echo not ok $n - BIP32 Test Vector 1 Chain m/0H/1, private derivation
fi

((n++)) # Example 6
if bx hd-public -d -i 2 xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs |
  grep -q xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5
then echo ok $n - BIP32 Test Vector 1 Chain m/0H/1, private derivation
else echo not ok $n - BIP32 Test Vector 1 Chain m/0H/1, private derivation
fi

