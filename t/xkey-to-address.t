#!/usr/bin/env bash

# examples extracted from https://learnmeabitcoin.com/technical/derivation-paths

. bitcoin.sh

echo "1..60"

seed=67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af
declare -i n=0
while read path address
do
  ((n++))
  xxd -p -r <<<"$seed" |
  case "${path::4}" in
    /49h) bip49 -s "$path/N" ;;
    /84h) bip84 -s "$path/N" ;;
    *)    bip32 -s "$path/N" ;;
  esac |
  base58 -c |
  if read -r pubkey; [[ "$(bitcoinAddress "$pubkey")" = $address ]]
  then echo "ok $n - $path: $address"
  else echo "not ok $n - $path: expected $address, got $(bitcoinAddress "$pubkey")"
  fi
done <<EOF
/44h/0h/0h/0/0 1AZnveys2k5taGCCF743RtrWGwc58UMeq
/44h/0h/0h/0/1 1AMYJTJyV4o1hwNACJtfdXBW6BiD1f5FXb
/44h/0h/0h/0/2 1NPFFtSiFRatoeUf35rwYb8j8C1u7sVhGa
/44h/0h/0h/0/3 1L44VTYEzWesp8cxnXcPGbUzuwTYoSW9at
/44h/0h/0h/0/4 1FK85vpZavzZu6oBCvBcmD4FWXQT5fVYRu
/44h/0h/0h/0/5 12QaHfWLtyuMwNXuap3FscMY434bw4TS6n
/44h/0h/0h/0/6 1NeFG5BYAR9bnjAG72SDYKvNZBH4kPa8r1
/44h/0h/0h/0/7 1yF3BiHqbQKL4aRfNYHQt4ZpgNagC4nQe
/44h/0h/0h/0/8 144vmUhuAZJsV3m2GsP5Kqp55Pmzwx2gna
/44h/0h/0h/0/9 1DQM5w6C7gNaCKBxQV3rXKftcamRKDPQ2M
/44h/0h/0h/0/10 17XRvBac5xpgMVr6LbsDA56fgsaAed4oEV
/44h/0h/0h/0/11 1BSQC3Qn38UT2WVfcM6LdybkfE7tTGW5M2
/44h/0h/0h/0/12 1KUG4EDePnG97xQNXtuU9Xmp4sThqFvSoS
/44h/0h/0h/0/13 18sXnPcBnXBRFBYbqr85aKPPNpwT4f52a8
/44h/0h/0h/0/14 15S2gpAVvprN1GPE44oXCdtkA4L7yQtBkX
/44h/0h/0h/0/15 1FvC2STfbj7dcr2ApAPhagnSCP5Dmy79nH
/44h/0h/0h/0/16 15VZHWTEjnQuJSvUHzS7K6gmYjNv4A5cVJ
/44h/0h/0h/0/17 1N4S7Z43gb22PDCcpjHhX25cgDSLxegdWm
/44h/0h/0h/0/18 1MzS2BktGqokVM4kDuB6VavjLuib72W2je
/44h/0h/0h/0/19 1GDLeWJ4FcK2uiTFvLshtVcBArA7M9ECxq
/49h/0h/0h/0/0 3PfdXXVGY2HQUBvDfBsbF1HPYCbJzn2pCn
/49h/0h/0h/0/1 3Jr1Xg44oeqkeVnJSBRpnv5wEKcfq2yL3M
/49h/0h/0h/0/2 3B4TrV6UjRiiQC6tC2oqQV1YEXtzVZDGGX
/49h/0h/0h/0/3 3Qi4nGjJprauc3s5x1gX7DMQNkst5TmVs4
/49h/0h/0h/0/4 3MC2F24goHaSntZ7yP9fCbB9Y5c2hxGbgM
/49h/0h/0h/0/5 3LJ1hRawmLtFfMxqLjmuFKvh5ofsng7pnj
/49h/0h/0h/0/6 3G5EAX2BjRdsKMTYPHUAv8H3dg24w4GUHu
/49h/0h/0h/0/7 324QyBxZhyxsNi5TkTiQxGS2t99FzFaKHG
/49h/0h/0h/0/8 3MrmwaxN5zvdKcv6teUaowwhR8s92TmXbp
/49h/0h/0h/0/9 37oKLxbVrtWoh4BPwfV2ZAN8VHgXx71kUb
/49h/0h/0h/0/10 3JMeVbU9GvCGw8pyX4UDvhVxQDETyU2QfE
/49h/0h/0h/0/11 3BvmZCWDtACAdNM15JuH2KYZx4ZfCos4pV
/49h/0h/0h/0/12 3N3njcCVwPifybCE3kyXitt57HimRcYYRi
/49h/0h/0h/0/13 33G2FDnBQjLV1TmQMPoXAcaDjsDsdhJDTM
/49h/0h/0h/0/14 3FC5NQshZaqFzcNiHX3M5N6mT1FSFGRu7j
/49h/0h/0h/0/15 3DaXKNrwnvM1tcDqQA6fi4Lgnd97GdeviM
/49h/0h/0h/0/16 38G6QHTqqjwEzumpHq2CRcEmN8ZnMdxvqA
/49h/0h/0h/0/17 3HBx3PVJwBNm2VvnfCNkNwTP7dRxU2vQ8t
/49h/0h/0h/0/18 3CpeerCAFB4PJCiFcqoYUdRQb1JnBfydHh
/49h/0h/0h/0/19 34pes2A1tVYL1aWSymPqKMPdTXcHdTSG8g
/84h/0h/0h/0/0 bc1qacwy02va0hajhuge9xf5cl3mrm9hmj7jhpvc87
/84h/0h/0h/0/1 bc1qkphlwh6e5k0zpqpctpf88gz2xv5ukxcqvj2x45
/84h/0h/0h/0/2 bc1q4vj6ypwc3tzfeqr66cjkhdfqzk37f2x5fvw7k5
/84h/0h/0h/0/3 bc1q8w7sz3cml688p3ts0ae50sk4n7adn42w36pqld
/84h/0h/0h/0/4 bc1qxsnnzvpe7wllzfc8maqy4flh68l9llx084x3n9
/84h/0h/0h/0/5 bc1qm8y4x5p676cexxz4ypqdzq4p5pyp20g9paawla
/84h/0h/0h/0/6 bc1qfzrzfzg9kq8da6gc9n8fy4s26qhgmxz5tallrq
/84h/0h/0h/0/7 bc1qzscqf5rulv66aqns2tejlqmshuk3tz9lnpmm3x
/84h/0h/0h/0/8 bc1qmdqxv5qufde866gqyf7355rs8276kawt98v63a
/84h/0h/0h/0/9 bc1q6s6v8wr78fgyja8ds88sjm7jxayjzqxfhlnzx5
/84h/0h/0h/0/10 bc1q8ysdd6f9xe2lzdjmscg0g97a9x3hup2xkjfat8
/84h/0h/0h/0/11 bc1qhz63ht8xxwzccv2ja2stufg3zpxp6k5qlt5tws
/84h/0h/0h/0/12 bc1qvuw0q074q7sfn2r7zlak5auuuadj2kn59nsg0s
/84h/0h/0h/0/13 bc1qen0lyrmag0g4kgy2xulwfahfgjl803ha7cjs8y
/84h/0h/0h/0/14 bc1qu8hagwvfcecf64rycz9mutycphs677pfcpkxus
/84h/0h/0h/0/15 bc1q02tx6pa8zymn2fnnuflxxwd39tc5vaxpse0wq7
/84h/0h/0h/0/16 bc1quazvkkdhwus93vzhqk0zszxh03v74rr3pa2y8s
/84h/0h/0h/0/17 bc1qcfswpjtxdphx0gtwqpkhr5tzpnm8yfskfz2sh8
/84h/0h/0h/0/18 bc1qak5fdj3ns7g95j2akh4549kjjj9hycjz25xe4q
/84h/0h/0h/0/19 bc1qppmtqmppec2n45w5uhr3gked7xzqh8z07h7r2t
EOF

# vi: ft=bash
