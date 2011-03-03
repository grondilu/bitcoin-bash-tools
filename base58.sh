#!/bin/bash
# Copyright (C) 2011 by Lucien Grondin
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# Requires bc, dc, openssl, xxd
#

base58=({1..9} {A..H} {J..N} {P..Z} {a..k} {m..z})
bitcoinregex="^[$(printf "%s" "${base58[@]}")]{34}$"

decodeBase58() {
    local s=$1
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
    openssl dgst -sha256 -binary |
    xxd -p -c 80 |
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
    openssl dgst -rmd160 -binary |
    xxd -p -c 80
}

hash160ToAddress() {
    printf "%34s\n" "$(encodeBase58 "00$1$(checksum "00$1")")" |
    sed "y/ /1/"
}

publicKeyToAddress() {
    hash160ToAddress $(
    openssl ec -pubin -pubout -outform DER |
    tail -c 65 |
    hash160
    )
}

timestamp() {
    hash160ToAddress "$(hash160)"
}

bigEndianHex2littleEndianHex() {
    local s=''
    while read -n 2 char
    do s=$char$s
    done
    echo $s
}

bitcoinHash() {
    bigEndianHex2littleEndianHex |
    xxd -p -r |
    openssl dgst -sha256 -binary |
    openssl dgst -sha256 -binary |
    xxd -p -80 |
    bigEndianHex2littleEndianHex
}
