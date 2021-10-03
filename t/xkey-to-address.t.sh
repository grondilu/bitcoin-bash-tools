#!/usr/bin/bash

# examples extracted from https://learnmeabitcoin.com/technical/derivation-paths

. bitcoin.sh
. bip-0032.sh

echo "1..20"

seed=b5f14640decb6bc5d1b52cba34f75a4643c3cd0096e1ec7adddca66c22e6b15e18118295fafe3766a38122f80fd3894e0a3ebbab6bdd7626dc1aefeb9c59ac52
declare -a bip44=(
  1LBfp6GkgPrCV9y1jTWRFA9b4GyjcZh3Ww
  1Pm5nEaXQ7QD33ToheE1njxVguDBuNfCgN
  1PdHpP1XY7YVmc3Hzqvr4J96htps77kApV
  1HhK7y3az5PKxeQkhmu9csbc73Th8uh5Ac
  1MJwwjmHvJGqHKPXAcSs641gPJi3CeigyL
  1EkYX36wvfFAPxmsfeMy2DwRHUMEU9axxq
  14aXeP7kUmmWN6bZqetKAwKjVoALnrad3p
  1Axr9h8atojNHq3S1Mc6ykbkVmd46N5cPn
  1PrLz8yhrpUH7xQdDTtTGXfYp1JG7aXaVo
  1MjhhR9TmAUFYwp5AHeNPs6vm4Uedtc8g2
  1P93tio4J9K5sDTyVWXv2K7aMsL6y8gQh2
  18gv6wnRqxWWbvzeBwS7wRNTckdxVfreV2
  1N39YpXqMs1ffUijswj7aAi738eeuv3e6o
  1GtfrdKc95VNeh56vWDM4aPcbiKwYgYrVa
  1MdL2rCa2mgsAZP5bovXRuEWq47ERXJ592
  1DoxPu2RkUR4msiGZ51NPWHvpZp5zwvLgo
  16YZCM6pAWdcwUPpYcKGzXoX5Lzva8BHot
  1FDHU4ZN5i5Um3c2jSRoW1f1xF1HSxEt2V
  1LgctGK9eo4tz7Cyw8SF4tGvvSLtj6sqrM
  1Mt7RZoc4mKW3vsyFxyY5EAQSGDtRY13gc
)

declare -i n=0
for i in {0..19}
do
  ((n++))
  path=/44h/0h/0h/0/$i
  xxd -p -r <<<"$seed" |
  bip32 "$path/N" |
  {
    read -r xpubkey
    if [[ "$(bitcoinAddress "$xpubkey")" = ${bip44[i]} ]]
    then echo "ok $n - $path: ${bip44[i]}"
    else echo "not ok $n - $path: expected ${bip44[i]}, got $(bitcoinAddress "$xpubkey")"
    fi
  }
done
