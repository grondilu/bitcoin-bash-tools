#!/usr/bin/bash

# examples extracted from https://learnmeabitcoin.com/technical/derivation-paths

. bitcoin.sh
. bip-0032.sh
. bip-0049.sh
. bip-0084.sh

echo "1..60"

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

declare -a bip49=(
  3K8xDAJAiMLJ7DG9PKzQfT97sZmDUV1Eyn
  3KQASQ2jgT9frWZWGeF6owtrve5XgK2V19
  377oZaCuiUjkeDtHRggZjsAgwtNKECYDw8
  3LezkRKYr2BPdRrPXLrh7YUDCQXZ9VpEYG
  3DwgXNHms3XV1FZH2DRE8CXqJDFKjZPMR4
  34g5kxR92Qs7hBt2qYyFTMw95qca5xHaT6
  3BLkJUMwAx2VqBRNrSAhovyyhqcsFPdGkc
  3Ju2iFoeNU1ZNAChsTStXeaymnGK1stvUc
  3PuX9caB7LFf78e92KuJX1YjrGQSWr2Hhg
  3DoHF5cZSF4g2JdxZGimrCrcy9KnoL5sfJ
  3FxN4kX9sXFegF8BxWvXVmh3mgUXyu279n
  3DoQu71wudhkvE3JMJv64pgLCHoUVry9X6
  3357aJgZCHjBkHXFfxeLDyNHqUCzFHFrvS
  35ysqAPaXZezdUz2wwcvQpE76hD45J12bY
  3CbP2V68A6155Sn3ANioYyLwzstomdKCoB
  3M79iMukPB4NRDCj3YWMMwbY5juvd7qNh7
  33f9XE7g733xR3PTiJPQ4iveg2uFVqT3vM
  31vwfzZWLxM4rJP953dX6ByrRJUGmfxrb5
  39Yd9S7Qqjjz4GHniuHJB5J1eJGA8y45V2
  3Pk1LJZrZPe2nNfEZTv345fHogg4s3M9Di
)

declare bip84=(
  bc1qafhhn3n9cxavp92k5k4mnh7p73dgpaj5pdfwzz
  bc1q0sxlwxhc3xqsq9s3u8nc49na76ecvhff3q508k
  bc1q75rrufu3rpkdkas526cdrxfqw5ygma5s3g57m5
  bc1q763djn4ad4uvzaapx0uju3y7cv0uv9kmwk3na5
  bc1qw2m8svahap4q9zk2vxetjejhxau77dmvg24704
  bc1q58rah8rms0w84r0aclgxde4uf7h7zzumhp98cj
  bc1qnzz4fzxrsyh63gs4j05krk343my0nea7vzypt9
  bc1qht2h5luy0rn2eswduxas7eyvlp8jtmz5nuug0t
  bc1qkwrumv9nkv0egek3q7a9mhyrv7zrdzk0788r73
  bc1qfujhm79xkx9xmd27anld6v2qp38vh7fuz5ck5d
  bc1qygwcsmr4wrwef6hqcsamhdgv3nek4977nl39ry
  bc1qfh35dzfe64l6m5t9gfxdxkxcnft36x2jy8uzpq
  bc1qzg59yuzr8vthd5wagjccqvzcnrl7j63yzh5u7r
  bc1qxskhzfd65mzcy55z47xlvatwv8gmhga9mld2a9
  bc1qe2w3f5mv6wuwrrx4le0e7rxzzz5rs4y0r6e6d8
  bc1qtduecpujtezhudg0574mxw9ufmzyqnz0xd5cfa
  bc1qj4edcj6phrw58a8n4zjzptv4sd5yktkswswgfg
  bc1qlux38s0rt7yrn4hvxyek6mt2hwcxzcz2nlnz5t
  bc1qm9mavhu7pwx370cundzmt5gekef73uyjt0yej3
  bc1qjd0tzgt5u6lxjhpnx7wxxhru0uwq8h5jtukxnf
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

for i in {0..19}
do
  ((n++))
  path=/49h/0h/0h/0/$i
  xxd -p -r <<<"$seed" |
  bip49 "$path/N" |
  {
    read -r ypubkey
    if [[ "$(bitcoinAddress "$ypubkey")" = ${bip49[i]} ]]
    then echo "ok $n - $path: ${bip49[i]}"
    else echo "not ok $n - $path: expected ${bip49[i]}, got $(bitcoinAddress "$ypubkey")"
    fi
  }
done

for i in {0..19}
do
  ((n++))
  path=/84h/0h/0h/0/$i
  xxd -p -r <<<"$seed" |
  bip84 "$path/N" |
  {
    read -r zpubkey
    if [[ "$(bitcoinAddress "$zpubkey")" = ${bip84[i]} ]]
    then echo "ok $n - $path: ${bip84[i]}"
    else echo "not ok $n - $path: expected ${bip84[i]}, got $(bitcoinAddress "$zpubkey")"
    fi
  }
done
