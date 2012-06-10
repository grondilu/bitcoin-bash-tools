#!/bin/bash
# Various bash bitcoin tools
#
# requires dc, the unix desktop calculator (which should be included in the
# 'bc' package)

declare -a base58=(
      1 2 3 4 5 6 7 8 9
    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h i j k   m n o p q r s t u v w x y z
)
unset dcr; for i in {0..57}; do dcr+="${i}s${base58[i]}"; done
declare ec_dc='
I16iFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2Fsp
7sb0sa483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798lp*+sG
FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141soilpsm
[[_1*lm1-*lm%q]Std0>tlm%Lts#]s%[_1*l%x]s_[+l%x]s+[*l%x]s*[-l%x]s-[Smdd
l%x-lm/rl%xLms#]s~[l%xsclmsd1su0sv0sr1st[q]SQ[lc0=Qldlcl~xlcsdscsqlrlq
lu*-ltlqlv*-lulvstsrsvsulXx]dSXxLXs#LQs#lrl%x]sI[lpSm[+q]S0d0=0lpl~xsy
dsxd*3*lal+x2ly*lIx*l%xdsld*2lx*l-xdlxrl-xlll*xlyl-xrlp*+Lms#L0s#]sD[lp
Sm[+q]S0[2;AlDxq]Sdd0=0rd0=0d2:Alp~1:A0:Ad2:Blp~1:B0:B2;A2;B=d[0q]Sx2;A
0;B1;Bl_xrlm*+=x0;A0;Bl-xlIxdsi1;A1;Bl-xl*xdsld*0;Al-x0;Bl-xd0;Arl-xll
l*x1;Al-xrlp*+L0s#Lds#Lxs#Lms#]sA[rs.0r[rl.lAxr]SP[q]sQ[d0!<Qd2%1=P2/l.
lDxs.lLx]dSLxs#LPs#LQs#]sM
';

decodeBase58() {
    dc -e "$dcr 16o0$(sed 's/./ 58*l&+/g' <<<$1)p" |
    while read n; do echo -n ${n/\\/}; done
}
encodeBase58() {
    dc -e "16i ${1^^} [3A ~r d0<x]dsxx +f" |
    while read -r n; do echo -n "${base58[n]}"; done
}

checksum() {
    perl -we "print pack 'H*', '$1'" |
    openssl dgst -sha256 -binary |
    openssl dgst -sha256 -binary |
    perl -we "print unpack 'H8', join '', <>"
}

checkBitcoinAddress() {
    if [[ "$1" =~ ^[$(IFS= ; echo "${base58[*]}")]+$ ]]
    then
	h="$(printf "%50s" $(decodeBase58 "$1")| sed 's/ /0/g')"
        checksum "${h:0:-8}" | grep -qi "^${h:${#h}-8}$"
    else return 2
    fi
}

hash160() {
    openssl dgst -sha256 -binary |
    openssl dgst -rmd160 -binary |
    perl -we "print unpack 'H*', join '', <>"
}

hexToAddress() {
    local version=${2:-00} x="$(printf "%${3:-40}s" $1 | sed 's/ /0/g')"
    printf "%34s\n" "$(encodeBase58 "$version$x$(checksum "$version$x")")" |
    {
	if ((version == 0))
	then sed -r 's/ +/1/'
	else cat
	fi
    }
}

new-bitcoin-key() {
    local exponant="$(openssl rand -rand <(date +%s%N; ps -ef) -hex 32 2>&-)"
    local wif="$(hexToAddress "$exponant" 80 64)"
    dc -e "$ec_dc lG I16i${exponant^^}ri lMx 16olm~ n[ ]nn" |
    {
	read -r y x
	public_key="$(printf "04%64s%64s" $x $y | sed 's/ /0/g')"
	h="$(perl -e "print pack q(H*), q($public_key)" | hash160)"
	addr="$(hexToAddress "$h")"
	cat <<-...
	---
	WIF:              $wif
	bitcoin address:  $addr
	public key:       $public_key
	...
    }
}
    
vanityAddressFromPublicPoint() {
    if [[ "$1" =~ ^04([0-9A-F]{64})([0-9A-F]{64})$ ]]
    then
	dc <<<"$ec_dc 16o
	0 ${BASH_REMATCH[0]} ${BASH_REMATCH[1]} rlp*+ 
	[lGlAxdlm~rn[ ]nn[ ]nr1+prlLx]dsLx
	" |
	while read -r x y n
	do
	    public_key="$(printf "04%64s%64s" $x $y | sed 's/ /0/g')"
	    h="$(perl -e "print pack q(H*), q($public_key)" | hash160)"
	    addr="$(hexToAddress "$h")"
	    if [[ "$addr" =~ "$2" ]]
	    then
		echo "FOUND! $n: $addr"
		return
	    else echo "$n: $addr"
	    fi
	done
    else 
	echo unexpected format for public point >&2
	return 1
    fi
}
