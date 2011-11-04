#!/bin/bash
# Satoshi Nakamoto's Base58 encoding
#
# requires dc, the unix desktop calculator (which should be included in the
# 'bc' package)

declare -a base58=({1..9} {A..H} {J..N} {P..Z} {a..k} {m..z})
unset dcr; for i in {0..57}; do dcr+="${i}s${base58[i]}"; done     # dc registers

decodeBase58() {
    dc -e "$dcr 16o0$(sed 's/./ 58*l&+/g' <<<$1)p" |
    while read l; do echo -n "$l"; done
}

encodeBase58() {
    dc -e "16i ${1^^} [3A ~r d0<x]dsxx +f" |
    while read n; do echo -n "${base58[n]}"; done
}

checksum() {
    perl -we "print pack 'H*', '$1'" |
    openssl dgst -sha256 -binary |
    openssl dgst -sha256 -binary |
    perl -we "print unpack 'H8', <>"
}

checkBitcoinAddress() {
    if [[ "$1" =~ ^[$(IFS= ; echo "${base58[*]}")]+$ ]]
    then
	# a bitcoin address should be 25 bytes long:
	# - 20 bytes for the hash160 (16/8 = 2, right?);
	# -  1 byte  for the version number;
	# -  4 bytes for the checksum.
	# shorter addresses can only occur with standard 00 version number
	# and should be zero padded
	# Of course, in hex you must mutiply these numbers by 2
	# to get the number of nybbles (hex digits)
	h="$(printf "%50s" $(decodeBase58 "$1")| sed 's/ /0/g')"
        checksum "${h::${#h}-8}" |
        grep -qi "^${h: -8}$"
    else return 2
    fi
}

hash160() {
    openssl dgst -sha256 -binary |
    openssl dgst -rmd160 -binary |
    perl -we "print unpack 'H*', <>"
}

hashToAddress() {
    local version="${2:-00}" size="${3:-160}"
    local x="$(dc -e "${size}ss 16dio 2 ls^ ${version^^}* ${1^^}+p")"
    printf "%34s\n" "$(encodeBase58 "$x$(checksum "$x")")" |
    sed -r "s/ +/1/"
}

publicKeyToAddress() {
    hashToAddress "$(
    openssl ec -pubin -pubout -outform DER 2>&- |
    tail -c 65 |
    hash160
    )" "${1:-00}"
}

privateKeyToWIF() {
    hashToAddress "$(
    openssl ec -text -noout 2>&- |
    sed -n '3,5s/[: ]//gp' |
    while read l; do echo -n "$l"; done
    )" 80 256
}

WIFtoDER() {
    printf "%64s\n" "$(dc -e "16dio $(decodeBase58 $1) 100 4^ / 80 100 20^*-p")" |
    sed 's/ /0/g'
}

vanityAddress() {
    local addr priv
    while ! grep -qi "${1:-1}" <<< "$addr"
    do
	priv="$(openssl ecparam -genkey -name secp256k1 2>&-)"
	addr="$(openssl ec -pubout 2>&- <<<"$priv" | publicKeyToAddress)"
	WIF="$(privateKeyToWIF <<<"$priv")"
    done
    echo "$addr, $WIF"
    echo "$priv"
}
