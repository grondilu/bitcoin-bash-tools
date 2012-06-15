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
I16i7sb0sa[[_1*lm1-*lm%q]Std0>tlm%Lts#]s%[Smddl%x-lm/rl%xLms#]s~
483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
2 100^d14551231950B75FC4402DA1732FC9BEBF-so1000003D1-ddspsm*+sGi
[_1*l%x]s_[+l%x]s+[*l%x]s*[-l%x]s-[l%xsclmsd1su0sv0sr1st[q]SQ[lc
0=Qldlcl~xlcsdscsqlrlqlu*-ltlqlv*-lulvstsrsvsulXx]dSXxLXs#LQs#lr
l%x]sI[lpSm[+q]S0d0=0lpl~xsydsxd*3*lal+x2ly*lIx*l%xdsld*2lx*l-xd
lxrl-xlll*xlyl-xrlp*+Lms#L0s#]sD[lpSm[+q]S0[2;AlDxq]Sdd0=0rd0=0d
2:Alp~1:A0:Ad2:Blp~1:B0:B2;A2;B=d[0q]Sx2;A0;B1;Bl_xrlm*+=x0;A0;B
l-xlIxdsi1;A1;Bl-xl*xdsld*0;Al-x0;Bl-xd0;Arl-xlll*x1;Al-xrlp*+L0
s#Lds#Lxs#Lms#]sA[rs.0r[rl.lAxr]SP[q]sQ[d0!<Qd2%1=P2/l.lDxs.lLx]
dSLxs#LPs#LQs#]sM[lm1+4/lp|]sS
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

newBitcoinKey() {
    if [[ "$1" =~ ^5 ]] && checkBitcoinAddress "$1" || checkBitcoinAddress "$1" 80 33;
    then
	decoded="$(decodeBase58 "$1")"
	if [[ "$decoded" =~ ^80([0-9A-F]{64})(01)?[0-9A-F]{8}$ ]]
	then $FUNCNAME "0x${BASH_REMATCH[1]}"
	fi
    elif [[ "$1" =~ ^[0-9]+$ ]]
    then $FUNCNAME "0x$(dc -e "16o$1p")"
    elif [[ "${1^^}" =~ ^0X([0-9A-F]+)$ ]]
    then 
	local exponant="${BASH_REMATCH[1]}"
	local uncompressed_wif="$(hexToAddress "$exponant" 80 64)"
	local compressed_wif="$(hexToAddress "${exponant}01" 80 66)"
	dc -e "$ec_dc lG I16i${exponant^^}ri lMx 16olm~ n[ ]nn" |
	{
	    read y x
	    uncompressed_public_key="$(printf "04%64s%64s" $x $y | sed 's/ /0/g')"
	    if [[ "$y" =~ [02468ACE]$ ]]
	    then y_parity="02"
	    else y_parity="03"
	    fi
	    compressed_public_key="$(printf "03%64s$y_parity" $x | sed 's/ /0/g')"
	    uncompressed_addr="$(hexToAddress "$(perl -e "print pack q(H*), q($uncompressed_public_key)" | hash160)")"
	    compressed_addr="$(hexToAddress "$(perl -e "print pack q(H*), q($compressed_public_key)" | hash160)")"
	    echo ---
            echo "secret exponant:          0x$exponant"
            echo "compressed:"
            echo "    WIF:                  $compressed_wif"
            echo "    bitcoin address:      $compressed_addr"
            echo "    public key:           $compressed_public_key"
            echo "uncompressed:"
            echo "    WIF:                  $uncompressed_wif"
            echo "    bitcoin address:      $uncompressed_addr"
            echo "    public key:           $uncompressed_public_key"
	}
    elif test -z "$1"
    then $FUNCNAME "0x$(openssl rand -rand <(date +%s%N; ps -ef) -hex 32 2>&-)"
    else
	echo unknown key format "$1" >&2
	return 2
    fi
}

vanityAddressFromPublicPoint() {
    if [[ "$1" =~ ^04([0-9A-F]{64})([0-9A-F]{64})$ ]]
    then
	dc <<<"$ec_dc 16o
	0 ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} rlp*+ 
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

insertBlock() {
    perl -wE '
    use Bitcoin::Block;
    use DBI;
    my $dbh = DBI->connect(q{dbi:mysql:bitcoin}, undef, undef);
    my $sth = $dbh->prepare(qq{
    insert into block (hash, version, hashPrev, hashMerkleRoot, nTime, nBits, nNonce)
    values            (   ?,       ?,        ?,              ?,     ?,     ?,      ?)
    });
    my $b = new Bitcoin::Block q{'"$1"'};
    my $h = $b->header;
    $sth->bind_param(1, $h->get_hash);
    $sth->bind_param(2, $h->version);
    $sth->bind_param(3, $h->hashPrev);
    $sth->bind_param(4, $h->hashMerkleRoot);
    $sth->bind_param(5, $h->nTime);
    $sth->bind_param(6, $h->nBits);
    $sth->bind_param(7, $h->nNonce);
    $sth->execute;
    ';
}

viewBlock() {
    if [[ -z "$1" ]]
    then return
    elif [[ "$1" =~ ^[0-9]{,10}$ ]]
    then where="depth = $1"
    elif [[ "$1" =~ ^[0-9A-F]{64}$ ]]
    then where="hash = unhex('$1')"
    fi
    mysql bitcoin <<<"
    select
	hex(hash),
	version,
	hex(hashPrev) as hashPrev,
	hex(hashMerkleRoot) as hashMerkleRoot,
	from_unixtime(nTime) as nTime,
	nBits as nBits,
	nNonce as nNonce,
	work,
	depth
    from block
    where $where
    \G
    "
}
