#!/bin/bash
# 
# Requires bc, dc, openssl, xxd
#

base58=({1..9} {A..H} {J..N} {P..Z} {a..k} {m..z})
bitcoinregex="^[$(printf "%s" "${base58[@]}")]{34}$"

decodeBase58() {
    s=$1
    for i in {0..57}
    do s="${s//${base58[i]}/ $i}"
    done
    dc <<< "16o0d${s// /+58*}+f" 
}

encodeBase58() {
    # 58 = 0x3A
    bc <<<"ibase=16; n=${1^^}; while(n>0) { n%3A ; n/=3A }" |
    tac |
    while read n
    do echo -n ${base58[n]}
    done
}

checksum() {
    xxd -p -r <<<"$1" |
    openssl dgst -sha256 -binary |
    openssl dgst -sha256 -hex |
    sed 's/^.* //' |
    head -c 8
}

checkBitcoinAddress() {
    if [[ "$1" =~ $bitcoinregex ]]
    then
        h=$(decodeBase58 "$1")
        checksum "00${h::${#h}-8}" |
        grep -qi "^${h: -8}$"
    else return 2
    fi
}

hash160() {
    openssl dgst -sha256 -binary |
    openssl dgst -rmd160 -hex |
    sed 's/^.* //'
}

hash160ToAddress() {
    printf %34s "$(encodeBase58 "00$1$(checksum "00$1")")" |
    sed "y/ /1/"
}

publicKeyToAddress() {
    hash160ToAddress $(
    openssl ec -pubin -pubout -outform DER 2>/dev/null |
    tail -c 65 |
    hash160
    )
}
