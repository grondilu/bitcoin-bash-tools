#!/usr/bin/env bash
# Various bash bitcoin tools
#
# This script uses GNU tools.  It is therefore not guaranted to work on a POSIX
# system.
#
# Requirements are detailed in the accompanying README file.
#
# Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
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
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

secp256k1="
I16i7sb0sa[[_1*lm1-*lm%q]Std0>tlm%Lts@]s%[Smddl%x-lm/rl%xLms@]s~
[[L0s@0pq]S0d0=0l<~2%2+l<*+[0]Pp]sE[_1*l%x]s_[+l%x]s+2 100^ds<d
14551231950B75FC4402DA1732FC9BEBF-sn1000003D1-dspsm [I1d+d+d*i1
483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
4Ri]dsgx3Rs@l<*+sG[*l%x]s*[-l%x]s-[l%xSclmSd1Su0Sv0Sr1St[q]SQ[lc
0=Qldlcl~xlcsdscsqlrlqlu*-ltlqlv*-lulvstsrsvsulXx]dSXxLXs@LQs@Lc
s@Lds@Lus@Lvs@Lrl%xLts@]sI[lpd1+4/r|]sRi[lpSm[+lCxq]S0[l1lDxlCxq
]Sd[0lCxq]SzdS1rdS2r[L0s@L1s@L2s@Lds@Lms@LCs@]SCd0=0rd0=0r=dl1l<
/l2l</l-xd*l1l<%l2l<%l+xd*+0=zl2l</l1l</l-xlIxl2l<%l1l<%l-xl*xd2
lm|l1l</l2l</+l-xd_3Rl1l</rl-xl*xl1l<%l-xrl<*+lCx]sA[lpSm[LCxq]
S0dl<~SySx[Lms@L0s@LCs@Lxs@Lys@]SC0=0lxd*3*la+ly2*lIxl*xdd*lx2*
l-xd_3Rlxrl-xl*xlyl-xrl<*+lCx]sD[rS.0r[rl.lAxr]SP[q]SQ[d0=Qd2%1
=P2/l.lDxs.lLx]dSLxs@L.s@LLs@LPs@LQs@]sM[[d2%1=_q]s2 2 2 8^^~dsx
d3lp|rla*+lb+lRxr2=2d2%0=_]sY[2l<*2^+]sU[d2%2+l<*rl</+]sC[l<~dlY
x3R2%rd3R+2%1=_rl<*+]s>[1_3R]sj[3Rd_3Rdl*xd_3RlIxl*x_4Rl*xlIxl*x
r]sf[[LQs@q]SQ3Rd_4R0=QLQs@[3R0*_3RLQs@q]SQrd_3R0=QLQs@rdd*lm%3R
d3Rd3R4**lm%3Rd*3*lm%5R5R*2*lm%rdd*lm%4Rd_3R2*l-xd_6Rl-x*3Rd*8*
l-x3R]s:[_4RSXSYSZ[s@0ddL0s@q]S0d0=0[_4RlZlYlXlPx4R]S+[q]SQ0dd4R
[d0=Qd2%1=+2/lZlYlXl:xsXsYsZlLx]dSLxLXs@LYs@LZs@s@LLs@L0s@L+s@LQ
s@]s;[3Rd[s@s@s@Lqs@q]Sq0=qLqs@6Rd[s@4Rs@4Rs@_3RLqs@q]Sq0=qLqs@d
dl*xd3Rd_4Rl*x6Rd3Rl*x3R6Rd3Rl*x6Rddl*xd3Rd_4Rl*x5d+Rl*x9R3Rl*x4
Rd_3Rl-x3R6Rd_3Rl-x3R[[s@s@s@s@s@s@0 0 0L1s@L2s@3Q]S2s@0*0=2s@s@
4Rs@_3Rl:xL1s@L2s@q]S1d0=1L1s@6Rs@6Rs@ddl*xd3Rd3Rl*x4Rddl*x7R6R
l*xd2l*x5Rd5R_4R_4R+l-xd4Rr5R_3Rl-xl*x5R4Rl*xl-x_5R_5Rl*xl*xr3R]
sP[[[INFINITY]nLIs@q]SI3Rd0=I_3RLIs@IO_5R_5Rlfx1d+d+d*doi2 100^d
3Rr2*+_3Rr2%*+[0]nnAPoi]se"

ripemd160() {
  # https://github.com/openssl/openssl/issues/16994
  # "-provider legacy" for openssl 3.0 || fallback for old versions
  2>/dev/null openssl dgst -provider legacy -rmd160 -binary ||
  openssl dgst -rmd160 -binary
}

hash160() {
  openssl dgst -sha256 -binary | ripemd160
}

ser32()
  if local -i i=$1; ((i >= 0 && i < 1<<32)) 
  then printf "%08X" $i |basenc --base16 -d
  else
    1>&2 echo index out of range
    return 1
  fi

ser256() (
  shopt -s extglob
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{65,})$ ]]
  then echo "unexpectedly large parameter" >&2; return 1
  elif   [[ "$1" =~ ^(0x)?([[:xdigit:]]{64})$ ]]
  then basenc --base16 -d <<<"${BASH_REMATCH[2]^^[a-f]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,63})$ ]]
  then $FUNCNAME "0x0${BASH_REMATCH[2]}"
  else return 1
  fi
)

base58()
  if
    local -a base58_chars=(
        1 2 3 4 5 6 7 8 9
      A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
      a b c d e f g h i j k   m n o p q r s t u v w x y z
    )
    local OPTIND OPTARG o
    getopts hdvc o
  then
    shift $((OPTIND - 1))
    case $o in
      h)
        cat <<-END_USAGE
	${FUNCNAME[0]} [options] [FILE]
	
	options are:
	  -h:	show this help
	  -d:	decode
	  -c:	append checksum
          -v:	verify checksum
	
	${FUNCNAME[0]} encode FILE, or standard input, to standard output.

	With no FILE, encode standard input.
	
	When writing to a terminal, ${FUNCNAME[0]} will escape non-printable characters.
	END_USAGE
        ;;
      d)
        local input
        read -r input < "${1:-/dev/stdin}"
        if [[ "$input" =~ ^1.+ ]]
        then printf "\x00"; ${FUNCNAME[0]} -d <<<"${input:1}"
        elif (IFS=; [[ "$input" =~ ^[${base58_chars[*]}]+$ ]])
        then dc -e "0${base58_chars[*]//?/ds&1+} 0${input//?/ 58*l&+}P"
        elif [[ -n "$input" ]]
        then return 1
        fi |
        if [[ -t 1 ]]
        then cat -v
        else cat
        fi
        ;;
      v)
        tee >(${FUNCNAME[0]} -d "$@" |head -c -4 |${FUNCNAME[0]} -c) |
        uniq | { read -r && ! read -r; }
        ;;
      c)
        tee >(
           openssl dgst -sha256 -binary |
           openssl dgst -sha256 -binary |
           head -c 4
        ) < "${1:-/dev/stdin}" |
        ${FUNCNAME[0]}
        ;;
    esac
  else
    basenc --base16 "${1:-/dev/stdin}" |
    tr -d '\n' |
    {
      read hex
      while [[ "$hex" =~ ^00 ]]
      do echo -n 1; hex="${hex:2}"
      done
      if test -n "$hex"
      then
        dc -e "16i0$hex Ai[58~rd0<x]dsxx+f" |
        while read -r
        do echo -n "${base58_chars[REPLY]}"
        done
      fi
      echo
    }
  fi

wif()
  if
    local OPTIND o
    getopts hutd o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} reads 32 bytes from stdin and interprets them
	as a bitcoin private key to display in Wallet Import Format (WIF).
	
	Usage:
	  ${FUNCNAME[0]} -h
	  ${FUNCNAME[0]} -d
	  ${FUNCNAME[0]} [-t][-u]
	
	The '-h' option displays this message.
	
	The '-u' option will place a suffix indicating that the key will be
	associated with a public key in uncompressed form.
	
	The '-t' option will generate addresses for the test network.
	
	The '-d' option performs the reverse operation : it reads a key in WIF
	and prints 32 bytes on stdout.  When writing to a terminal, non-printable
	characters will be escaped.
	END_USAGE
        ;;
      d) base58 -d |
         tail -c +2 |
         head -c 32 |
         if test -t 1
         then
           {
             # see https://stackoverflow.com/questions/48101258/how-to-convert-an-ecdsa-key-to-pem-format
             basenc --base16 -d <<< "302E0201010420"
             cat
             basenc --base16 -d <<< "A00706052B8104000A"
           } | openssl ec -inform der
         else cat
         fi
         ;;
      u) BITCOIN_PUBLIC_KEY_FORMAT=uncompressed ${FUNCNAME[0]} "$@";;
      t) BITCOIN_NET=TEST ${FUNCNAME[0]} "$@";;
    esac
  else
    {
      if [[ "$BITCOIN_NET" = TEST ]]
      then printf "\xEF"
      else printf "\x80"
      fi
      head -c 32
      if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" != uncompressed ]]
      then printf "\x01"
      fi
    } |
    base58 -c
  fi

# Bech32 code starts here {{{
# 
# Translated from javascript.
#
# Original code link:
# https://github.com/sipa/bech32/blob/master/ref/javascript/bech32.js
#
# Copyright and permission notice in original file :
# 
# // Copyright (c) 2017, 2021 Pieter Wuille
# //
# // Permission is hereby granted, free of charge, to any person obtaining a copy
# // of this software and associated documentation files (the "Software"), to deal
# // in the Software without restriction, including without limitation the rights
# // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# // copies of the Software, and to permit persons to whom the Software is
# // furnished to do so, subject to the following conditions:
# //
# // The above copyright notice and this permission notice shall be included in
# // all copies or substantial portions of the Software.
# //
# // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# // THE SOFTWARE.

declare bech32_charset="qpzry9x8gf2tvdw0s3jn54khce6mua7l"
declare -A bech32_charset_reverse
for i in {0..31}
do bech32_charset_reverse[${bech32_charset:$i:1}]=$((i))
done

declare -i BECH32_CONST=1

bech32()
  if local OPTIND OPTARG o
    getopts hmv: o
  then shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-EOF
	usage:
	  ${FUNCNAME[0]} -h
	  ${FUNCNAME[0]} [-m] hrp data
	EOF
      ;;
      m) BECH32_CONST=0x2bc830a3 ${FUNCNAME[0]} "$@" ;;
      v)
        if [[ "$OPTARG" =~ ^(.{1,83})1([$bech32_charset]{6,})$ ]]
        then
          ${FUNCNAME[0]} "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]::-6}" |
          grep -q "^$OPTARG$"
        else return 33
        fi
      ;;
    esac
  elif [[ "$1$2" =~ [A-Z] && "$hrp$data" =~ [a-z] ]]
  then return 1
  elif local hrp="${1,,}" data="${2,,}"
    (( ${#hrp} + ${#data} + 6 > 90 ))
  then return 2
  elif (( ${#hrp} < 1 || ${#hrp} > 83 ))
  then return 3
  elif 
    local -i ord p out_of_range=0
    for ((p=0;p<${#hrp};p++))
    do
      printf -v ord "%d" "'${hrp:p:1}"
      if ((ord < 33 || ord > 126))
      then out_of_range=1; break
      fi
    done
    ((out_of_range == 1))
  then return 4
  elif [[ "$data" =~ [^$bech32_charset] ]]
  then return 5
  else
    echo "${hrp}1$data$(
      bech32_create_checksum "$hrp" $(
        echo -n "$data" |
        while read -n 1; do echo "${bech32_charset_reverse[$REPLY]}"; done
      ) | while read; do echo -n "${bech32_charset:$REPLY:1}"; done
    )"
  fi

polymod() {
  local -ai generator=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  local -i chk=1 value
  for value
  do
    local -i top i
    
    ((top = chk >> 25, chk = (chk & 0x1ffffff) << 5 ^ value))
    
    for i in 0 1 2 3 4
    do (( ((top >> i) & 1) && (chk^=${generator[i]}) ))
    done
  done
  echo $chk
}

hrpExpand() {
  local -i p ord
  for ((p=0; p < ${#1}; ++p))
  do printf -v ord "%d" "'${1:p:1}"
    echo $(( ord >> 5 ))
  done
  echo 0
  for ((p=0; p < ${#1}; ++p))
  do printf -v ord "%d" "'${1:p:1}"
    echo $(( ord & 31 ))
  done
}

verifyChecksum() {
  local hrp="$1"
  shift
  local -i pmod="$(polymod $(hrpExpand "$hrp") "$@")"
  (( pmod == BECH32_CONST ))
}

bech32_create_checksum() {
  local hrp="$1"
  shift
  local -i p mod=$(($(polymod $(hrpExpand "$hrp") "$@" 0 0 0 0 0 0) ^ BECH32_CONST))
  for p in 0 1 2 3 4 5
  do echo $(( (mod >> 5 * (5 - p)) & 31 ))
  done
}

bech32_encode()
  if
    local OPTIND o
    getopts m o
  then
    shift $((OPTIND - 1))
    BECH32_CONST=0x2bc830a3 $FUNCNAME "$@"
  else
    local hrp=$1 i
    shift
    echo -n "${hrp}1"
    {
      for i; do echo $i; done
      bech32_create_checksum "$hrp" "$@"
    } |
    while read; do echo -n ${bech32_charset:$REPLY:1}; done
    echo
  fi

bech32_decode()
  if
    local OPTIND o
    getopts m o
  then
    shift $((OPTIND - 1))
    BECH32_CONST=0x2bc830a3 $FUNCNAME "$@"
  else
    local bechString=$1
    local -i p has_lower=0 has_upper=0 ord

    for ((p=0;p<${#bechString};++p))
    do
      printf -v ord "%d" "'${bechString:p:1}"
      if   ((ord <  33 || ord >  126))
      then return 1
      elif ((ord >= 97 && ord <= 122))
      then has_lower=1
      elif ((ord >= 65 && ord <= 90))
      then has_upper=1
      fi
    done
    if ((has_upper && has_lower))
    then return 2 # mixed case
    elif bechString="${bechString,,}"
      ((${#bechString} > 90))
    then return 3 # string is too long
    elif [[ ! "$bechString" =~ 1 ]]
    then return 4 # no separator
    elif
      local hrp="${bechString%1*}"
      test -z $hrp
    then return 5 # no human readable part
    elif local data="${bechString##*1}"
      ((${#data} < 6))
    then return 6 # data is too short
    else
      for ((p=0;p<${#data};++p))
      do echo "${bech32_charset_reverse[${data:p:1}]}"
      done |
      {
        mapfile -t
        if verifyChecksum "$hrp" "${MAPFILE[@]}"
        then
          echo $hrp
          for p in "${MAPFILE[@]::${#MAPFILE[@]}-6}"
          do echo $p
          done
        else return 8
        fi
      }
    fi
  fi

# bech32-related code ends here }}}

# bip-0173/bip-0350 code starts here {{{

p2wpkh() { segwitAddress -p "$1"; }

segwitAddress()
  if
    local OPTIND OPTARG o
    getopts hp:tv: o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} [-t] [-v witness-version] WITNESS_PROGRAM
	${FUNCNAME[0]} [-t] -p compressed-point
	END_USAGE
        ;;
      p)
        if [[ "$OPTARG" =~ ^0[23][[:xdigit:]]{64}$ ]]
        then ${FUNCNAME[0]} "$@" "$(
          basenc --base16 -d <<<"${OPTARG^^[a-f]}" |
          hash160 |
	  basenc --base16 -w0
        )"
        else echo "-p option expects a compressed point as argument" >&2
          return 1
        fi
        ;;
      t) HRP=tb ${FUNCNAME[0]} "$@" ;;
      v) WITNESS_VERSION=$OPTARG ${FUNCNAME[0]} "$@" ;;
    esac
  elif
    local hrp="${HRP:-bc}"
    [[ ! "$hrp"     =~ ^(bc|tb)$ ]]
  then return 1
  elif
    local witness_program="$1"
    [[ ! "$witness_program" =~ ^([[:xdigit:]]{2})+$ ]]
  then return 2
  elif
    local -i version=${WITNESS_VERSION:-0}
    ((version < 0))
  then return 3
  elif ((version == 0))
  then
    if [[ "$witness_program" =~ ^(.{40}|.{64})$ ]] # 20 or 32 bytes
    then
      # P2WPKH or P2WSH
      bech32_encode "$hrp" $(
        echo $version;
        echo -n "$witness_program" |
        while read -n 2; do echo 0x$REPLY; done |
        convertbits 8 5
      )
    else
       1>&2 echo For version 0, the witness program must be either 20 or 32 bytes long.
       return 4
    fi
  elif ((version <= 16))
  then
    bech32_encode -m "$hrp" $(
      echo $version
      echo -n "$witness_program" |
      while read -n 2; do echo 0x$REPLY; done |
      convertbits 8 5
     )
  else return 255
  fi

segwit_verify() {
  if bech32 -v "$1"
  then return 1
  else
    local hrp
    local -i witness_version
    local -ai bytes
    bech32_decode "$1" |
    {
      read hrp
      [[ "$hrp" =~ ^(bc|tb)$ ]] || return 2
      read witness_version
      (( witness_version < 0 || witness_version > 16)) && return 3
      
      bytes=($(convertbits 5 8 0)) || return 4
      if
        ((
          ${#bytes[@]} == 0 ||
          ${#bytes[@]} <  2 ||
          ${#bytes[@]} > 40
        ))
      then return 7
      elif ((
         witness_version == 0 &&
         ${#bytes[@]} != 20 &&
         ${#bytes[@]} != 32
      ))
      then return 8
      fi
    }
  fi
}

convertbits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  local -i maxv=$(( (1 << outbits) - 1 ))
  while read 
  do
    val=$(((val<<inbits)|$REPLY))
    ((bits+=inbits))
    while ((bits >= outbits))
    do
      (( bits-=outbits ))
      echo $(( (val >> bits) & maxv ))
    done
  done
  if ((pad > 0))
  then
    if ((bits))
    then echo $(( (val << (outbits - bits)) & maxv ))
    fi
  elif (( ((val << (outbits - bits)) & maxv ) || bits >= inbits))
  then return 1
  fi
}

segwit_decode()
  if
    local addr="$1"
    ! {
      bech32_decode "$addr" ||
      bech32_decode -m "$addr" 
    } >/dev/null
  then return 1
  else
    {
      bech32_decode "$addr" ||
      bech32_decode -m "$addr" 
    } |
    {
      local hrp
      read hrp
      if [[ ! "$hrp" =~ ^(bc|tb)$ ]]
      then return 2
      fi
      local -i version
      read version
      if ((version > 0)) && bech32_decode "$addr" >/dev/null
      then return 3
      elif ((version == 0)) && bech32_decode -m "$addr" >/dev/null
      then return 4
      elif ((version > 16))
      then return 5
      fi
      mapfile -t
      local p
      local -a bytes
      bytes=($(
        for p in ${MAPFILE[@]}
        do echo $p
        done |
        convertbits 5 8 0
      )) || return 6
      if
        ((
          ${#bytes[@]} == 0 ||
          ${#bytes[@]} <  2 ||
          ${#bytes[@]} > 40
        ))
      then return 7
      elif ((
         version == 0 &&
         ${#bytes[@]} != 20 &&
         ${#bytes[@]} != 32
      ))
      then return 8
      else
        echo $hrp
        echo $version
        printf "%02x" "${bytes[@]}"
        echo
      fi
    }
  fi

# bip-0173 code stops here }}}

# bip-0032 code starts here {{{
shopt -s extglob

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

isPrivate() ((
  $1 == BIP32_TESTNET_PRIVATE_VERSION_CODE ||
  $1 == BIP32_MAINNET_PRIVATE_VERSION_CODE
))

isPublic() ((
  $1 == BIP32_TESTNET_PUBLIC_VERSION_CODE ||
  $1 == BIP32_MAINNET_PUBLIC_VERSION_CODE
))

pegged-entropy()
  if (( ${#@} == 0 ))
  then
    echo "no peg was provided" >&2
    return 1
  elif ! test -t 0
  then
    echo "$FUNCNAME will only read input from a terminal" >&2
    return 2
  else
    local peg
    local -i i c
    {
      for peg in "$@"
      do
        read -p "$peg $((++i))/${#@}: "
        if ((REPLY > 99 || REPLY < 0))
        then
          echo "input out of range" >&2
          return 2
        fi
        # https://stackoverflow.com/questions/9134638/using-read-without-triggering-a-newline-action-on-terminal
        echo -en "\033[1A\033[2K" >&2
        ((c += REPLY))
        printf "%02d" "$REPLY"
      done
      echo " P"
      echo "checksum is $((c % 100))" >&2
    } |
    dc |
    if test -t 1
    then cat -v
    else cat
    fi
  fi

bip32() (
  shopt -s extglob
  local header_format='%08X%02X%08X%08X' 
  local OPTIND OPTARG o
  #echo "BIP32 $@" >&2
  if getopts hst o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	Usage:
	  $FUNCNAME -h
	  $FUNCNAME [-st] [derivation-path]
	
	$FUNCNAME generates extended keys as defined by BIP-0032.
	When writing to a terminal, $FUNCNAME will print the base58-checked version of the
	serialized key.  Otherwise, it will print the serialized key.
	
	With no argument, $FUNCNAME will generate an extended master key from a binary
	seed read on standard input.  With the -t option, it will generate such key
	for the test network.
	
	With a derivation path as an argument, $FUNCNAME will read a
	seralized extended key from stdin and generate the corresponding derived key.
	
	If the derivation path begins with 'm', $FUNCNAME will expect a master private key as input.
	If the derivation path begins with 'M', $FUNCNAME will expect a master public key as input.
	Otherwise the derivation path begins with '/', then $FUNCNAME will derive any key read from
	standard input.
	
	When expecting a serialized key from stdin, $FUNCNAME will only read the first 78 bytes.
	
	With the -s option, input is interpreted as a seed, not as a serialized key.
	With the -t option, input is interpreted as a seed, and a testnet master key is generated.
	END_USAGE
        ;;
      s) 
        {
          if [[ "$BITCOIN_NET" = TEST ]]
          then printf "$header_format" $BIP32_TESTNET_PRIVATE_VERSION_CODE 0 0 0
          else printf "$header_format" $BIP32_MAINNET_PRIVATE_VERSION_CODE 0 0 0
          fi
          #openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
	  openssl mac -digest sha512 -macopt key:"Bitcoin seed" -binary hmac |
	  basenc --base16 -w64 |
          tac |
          sed 2i00
        } |
	basenc --base16 -d |
        ${FUNCNAME[0]} "$@"
        ;;
      t) BITCOIN_NET=TEST ${FUNCNAME[0]} -s "$@";;
    esac
  elif (( $# > 1 ))
  then
    echo "too many parameters given : $@" >&2
    return 1
  elif [[ "$1" =~ ^[mM]?(/([[:digit:]]+h?|N))*$ ]]
  then
    local path="$1" hexdump="$(
      if test -t 0 
      then
        read -p "eXtended key: "
        base58 -d <<<"$REPLY"
      else cat
      fi |
      head -c 78 |
      basenc --base16 -w0
    )"
    if (( ${#hexdump} < 2*78 ))
    then echo "input is too short" >&2; return 2
    fi

    local -i      version="0x${hexdump:0:8}"
    local -i        depth="0x${hexdump:8:2}"
    local -i    parent_fp="0x${hexdump:10:8}"
    local -i child_number="0x${hexdump:18:8}"
    local      chain_code="${hexdump:26:64}"
    local             key="${hexdump:90:66}"

    # sanity checks
    if [[ "$path" =~ ^m ]] && ((
      version != BIP32_TESTNET_PRIVATE_VERSION_CODE &&
      version != BIP32_MAINNET_PRIVATE_VERSION_CODE
    ))
    then return 2
    elif [[ "$path" =~ ^M ]] && ((
      version != BIP32_TESTNET_PUBLIC_VERSION_CODE &&
      version != BIP32_MAINNET_PUBLIC_VERSION_CODE
    ))
    then return 3
    elif [[ "$path" =~ ^[mM] ]] && ((depth > 0))
    then return 4
    elif [[ "$path" =~ ^[mM] ]] && ((parent_fp > 0))
    then return 5
    elif [[ "$path" =~ ^[mM] ]] && ((child_number > 0))
    then return 6
    elif [[ ! "$key" =~ ^0[023] ]]
    then echo "unexpected key: $key (hexdump is $hexdump)" >&2; return 7
    elif ((
      version != BIP32_TESTNET_PRIVATE_VERSION_CODE &&
      version != BIP32_MAINNET_PRIVATE_VERSION_CODE &&
      version != BIP32_TESTNET_PUBLIC_VERSION_CODE  &&
      version != BIP32_MAINNET_PUBLIC_VERSION_CODE
    ))
    then return 8
    elif ((depth < 0 || depth > 255))
    then return 9
    elif ((parent_fp < 0 || parent_fp > 0xffffffff))
    then return 10
    elif ((child_number < 0 || child_number > 0xffffffff))
    then return 11
    elif isPublic  $version && [[ "$key" =~ ^00    ]]
    then return 12
    elif isPrivate $version && [[ "$key" =~ ^0[23] ]]
    then return 13
    # TODO: check that the point is on the curve?
    fi
    
    path="${path#[mM]}"
    if test -n "$path"
    then
      coproc DC { dc -e "$secp256k1" -; }
      trap 'echo q >&"${DC[1]}"' EXIT RETURN
      while [[ "$path" =~ ^/(N|[[:digit:]]+h?) ]]
      do  
        path="${path#/${BASH_REMATCH[1]}}"
        local operator="${BASH_REMATCH[1]}" 
        case "$operator" in
          N)
            case $version in
               $((BIP32_TESTNET_PUBLIC_VERSION_CODE)))
                 ;;
               $((BIP32_MAINNET_PUBLIC_VERSION_CODE)))
                 ;;
               $((BIP32_MAINNET_PRIVATE_VERSION_CODE)))
                 version=$BIP32_MAINNET_PUBLIC_VERSION_CODE;;&
               $((BIP32_TESTNET_PRIVATE_VERSION_CODE)))
                 version=$BIP32_TESTNET_PUBLIC_VERSION_CODE;;&
               *)
		#echo -n "$key ..." >&2
                echo "4d*doilgx${key^^}l;xlex" >&"${DC[1]}"
                read key <&"${DC[0]}"
		#echo "done" >&2
            esac
            ;;
          +([[:digit:]])h)
            child_number=$(( ${operator%h} + (1 << 31) ))
            ;&
          +([[:digit:]]))

            ((depth++))
            local parent_id
            if [[ ! "$operator" =~ h$ ]]
            then child_number=operator
            fi

            if isPrivate "$version"
            then # CKDpriv

              echo "4d*doilgx${key^^}l;xlex" >&"${DC[1]}"
              read parent_id <&"${DC[0]}"
              {
                {
                  if (( child_number >= (1 << 31) ))
                  then
                    printf "\x00"
                    ser256 "0x${key:2}" || echo "WARNING: ser256 return $?" >&2
                  else
                    basenc --base16 -d <<<"${parent_id^^[a-f]}"
                  fi
                  ser32 $child_number
                } |
                openssl dgst -sha512 -mac hmac -macopt hexkey:"$chain_code" -binary |
		basenc --base16 -w64 |
                {
                   read left
                   read right
                   echo "4d*doi$right ${key^^} $left+ln%p"
                }
              } >&"${DC[1]}"

            elif isPublic "$version"
            then # CKDpub
              parent_id="$key"
              if (( child_number >= (1 << 31) ))
              then
                echo "extented public key can't produce a hardened child" >&2
                return 4
              else
                {
                  {
                    basenc --base16 -d <<<"${key^^[a-f]}"
                    ser32 $child_number
                  } |
                  openssl dgst -sha512 -mac hmac -macopt hexkey:"$chain_code" -binary |
		  basenc --base16 -w64 |
                  {
                     read left
                     read right
                     echo "8d+doi$right lgx$left l;x ${key^^}l>x l<~rljx lPxlex 0"
                  }
                } >&"${DC[1]}"
              fi
            else
              echo "version is neither private nor public?!" >&2
              return 111
            fi
            read key <&"${DC[0]}"
            while ((${#key} < 66))
            do key="0$key"
            done
            echo rp >&"${DC[1]}"
            read chain_code <&"${DC[0]}"
            while ((${#chain_code} < 64))
            do chain_code="0$chain_code"
            done
            parent_fp="0x$(
	      basenc --base16 -d <<<"${parent_id^^[a-f]}"|
	      hash160 |
	      head -c 4 |
	      basenc --base16 -w0
	    )"
            ;;
        esac 
      done
    fi

    printf "$header_format%s%s" $version $depth $parent_fp $child_number "$chain_code" "$key" |
    basenc --base16 -d |
    if [[ -t 1 ]]
    then base58 -c
    else cat
    fi

  else return 255
  fi
)

# bip-0032 code stops here }}}

bip49() {
  BIP32_MAINNET_PUBLIC_VERSION_CODE=0x049d7cb2 \
  BIP32_MAINNET_PRIVATE_VERSION_CODE=0x049d7878 \
  BIP32_TESTNET_PUBLIC_VERSION_CODE=0x044a5262 \
  BIP32_TESTNET_PRIVATE_VERSION_CODE=0x044a4e28 \
  bip32 "$@"
}

bip84() {
  BIP32_MAINNET_PUBLIC_VERSION_CODE=0x04b24746 \
  BIP32_MAINNET_PRIVATE_VERSION_CODE=0x04b2430c \
  BIP32_TESTNET_PUBLIC_VERSION_CODE=0x045f1cf6 \
  BIP32_TESTNET_PRIVATE_VERSION_CODE=0x045f18bc \
  bip32 "$@"
}

alias xkey=bip32
alias ykey=bip49
alias zkey=bip84

bip85()
  case "$1" in
    wif)
      shift
      $FUNCNAME 2 "$@" |
      wif
      ;;
    xprv)
      $FUNCNAME 32 ${2:-0} |
      basenc --base16 -w64 |
      {
        read left
	read right
        printf '%08X%02X%08X%08X%s00%s' $BIP32_MAINNET_PRIVATE_VERSION_CODE 0 0 0 $left $right
      } |
      basenc --base16 -d |
      bip32
      ;;
    mnemo*)
      local -i words=${2:-12} index=${3:-0} lang ent=words*32/3
      (
	shopt -s extglob
	case "$LANG" in
	  ja?(_*))  lang=1;;
	  ko?(_*))  lang=2;;
	  es?(_*))  lang=3;;
	  zh_CN)    lang=4;;
	  zh_TW)    lang=5;;
	  fr?(_*))  lang=6;;
	  it?(_*))  lang=7;;
	  cz?(_*))  lang=8;;
	  *)        lang=0;;
	esac
	# CS = ENT / 32
	# MS = (ENT + CS) / 11
	$FUNCNAME 39 $lang $words $index
      ) |
	head -c $((ent/8)) |
	basenc --base16 -w$((2*(ent/8))) |
	{
	  read
	  create-mnemonic "$REPLY"
	}
      ;;
    hex)
      shift
      local -i num_bytes=${1:-16} index=${2:-0}
      if ((num_bytes < 16 || num_bytes > 64))
      then echo "number of bytes ($num_bytes) out of range" >&2
        return 46
      else 
        $FUNCNAME 128169 $num_bytes $index |
        head -c $num_bytes |
	basenc --base16 -w0
      fi
      ;;
    *)
      local path="m/83696968h/${1:-0}h/${2:-0}h"
      shift; shift;
      for i in "$@"
      do path="$path/${i}h"
      done
      {
        if test -t 0 
        then 
          read -p "extended master key: "
          base58 -d <<<"$REPLY"
        else cat
        fi
      } |
      bip32 "$path" |
      tail -c 32 |
      openssl dgst -sha512 -hmac "bip-entropy-from-k" -binary |
      if test -t 1
      then cat -v
      else cat
      fi
      ;;
  esac
  
# bip-0039 code starts here {{{

# lists of words from https://github.com/bitcoin/bips/tree/master/bip-0039
declare -a english=(abandon ability able about above absent absorb abstract absurd abuse access accident account accuse achieve acid acoustic acquire across act action actor actress actual adapt add addict address adjust admit adult advance advice aerobic affair afford afraid again age agent agree ahead aim air airport aisle alarm album alcohol alert alien all alley allow almost alone alpha already also alter always amateur amazing among amount amused analyst anchor ancient anger angle angry animal ankle announce annual another answer antenna antique anxiety any apart apology appear apple approve april arch arctic area arena argue arm armed armor army around arrange arrest arrive arrow art artefact artist artwork ask aspect assault asset assist assume asthma athlete atom attack attend attitude attract auction audit august aunt author auto autumn average avocado avoid awake aware away awesome awful awkward axis baby bachelor bacon badge bag balance balcony ball bamboo banana banner bar barely bargain barrel base basic basket battle beach bean beauty because become beef before begin behave behind believe below belt bench benefit best betray better between beyond bicycle bid bike bind biology bird birth bitter black blade blame blanket blast bleak bless blind blood blossom blouse blue blur blush board boat body boil bomb bone bonus book boost border boring borrow boss bottom bounce box boy bracket brain brand brass brave bread breeze brick bridge brief bright bring brisk broccoli broken bronze broom brother brown brush bubble buddy budget buffalo build bulb bulk bullet bundle bunker burden burger burst bus business busy butter buyer buzz cabbage cabin cable cactus cage cake call calm camera camp can canal cancel candy cannon canoe canvas canyon capable capital captain car carbon card cargo carpet carry cart case cash casino castle casual cat catalog catch category cattle caught cause caution cave ceiling celery cement census century cereal certain chair chalk champion change chaos chapter charge chase chat cheap check cheese chef cherry chest chicken chief child chimney choice choose chronic chuckle chunk churn cigar cinnamon circle citizen city civil claim clap clarify claw clay clean clerk clever click client cliff climb clinic clip clock clog close cloth cloud clown club clump cluster clutch coach coast coconut code coffee coil coin collect color column combine come comfort comic common company concert conduct confirm congress connect consider control convince cook cool copper copy coral core corn correct cost cotton couch country couple course cousin cover coyote crack cradle craft cram crane crash crater crawl crazy cream credit creek crew cricket crime crisp critic crop cross crouch crowd crucial cruel cruise crumble crunch crush cry crystal cube culture cup cupboard curious current curtain curve cushion custom cute cycle dad damage damp dance danger daring dash daughter dawn day deal debate debris decade december decide decline decorate decrease deer defense define defy degree delay deliver demand demise denial dentist deny depart depend deposit depth deputy derive describe desert design desk despair destroy detail detect develop device devote diagram dial diamond diary dice diesel diet differ digital dignity dilemma dinner dinosaur direct dirt disagree discover disease dish dismiss disorder display distance divert divide divorce dizzy doctor document dog doll dolphin domain donate donkey donor door dose double dove draft dragon drama drastic draw dream dress drift drill drink drip drive drop drum dry duck dumb dune during dust dutch duty dwarf dynamic eager eagle early earn earth easily east easy echo ecology economy edge edit educate effort egg eight either elbow elder electric elegant element elephant elevator elite else embark embody embrace emerge emotion employ empower empty enable enact end endless endorse enemy energy enforce engage engine enhance enjoy enlist enough enrich enroll ensure enter entire entry envelope episode equal equip era erase erode erosion error erupt escape essay essence estate eternal ethics evidence evil evoke evolve exact example excess exchange excite exclude excuse execute exercise exhaust exhibit exile exist exit exotic expand expect expire explain expose express extend extra eye eyebrow fabric face faculty fade faint faith fall false fame family famous fan fancy fantasy farm fashion fat fatal father fatigue fault favorite feature february federal fee feed feel female fence festival fetch fever few fiber fiction field figure file film filter final find fine finger finish fire firm first fiscal fish fit fitness fix flag flame flash flat flavor flee flight flip float flock floor flower fluid flush fly foam focus fog foil fold follow food foot force forest forget fork fortune forum forward fossil foster found fox fragile frame frequent fresh friend fringe frog front frost frown frozen fruit fuel fun funny furnace fury future gadget gain galaxy gallery game gap garage garbage garden garlic garment gas gasp gate gather gauge gaze general genius genre gentle genuine gesture ghost giant gift giggle ginger giraffe girl give glad glance glare glass glide glimpse globe gloom glory glove glow glue goat goddess gold good goose gorilla gospel gossip govern gown grab grace grain grant grape grass gravity great green grid grief grit grocery group grow grunt guard guess guide guilt guitar gun gym habit hair half hammer hamster hand happy harbor hard harsh harvest hat have hawk hazard head health heart heavy hedgehog height hello helmet help hen hero hidden high hill hint hip hire history hobby hockey hold hole holiday hollow home honey hood hope horn horror horse hospital host hotel hour hover hub huge human humble humor hundred hungry hunt hurdle hurry hurt husband hybrid ice icon idea identify idle ignore ill illegal illness image imitate immense immune impact impose improve impulse inch include income increase index indicate indoor industry infant inflict inform inhale inherit initial inject injury inmate inner innocent input inquiry insane insect inside inspire install intact interest into invest invite involve iron island isolate issue item ivory jacket jaguar jar jazz jealous jeans jelly jewel job join joke journey joy judge juice jump jungle junior junk just kangaroo keen keep ketchup key kick kid kidney kind kingdom kiss kit kitchen kite kitten kiwi knee knife knock know lab label labor ladder lady lake lamp language laptop large later latin laugh laundry lava law lawn lawsuit layer lazy leader leaf learn leave lecture left leg legal legend leisure lemon lend length lens leopard lesson letter level liar liberty library license life lift light like limb limit link lion liquid list little live lizard load loan lobster local lock logic lonely long loop lottery loud lounge love loyal lucky luggage lumber lunar lunch luxury lyrics machine mad magic magnet maid mail main major make mammal man manage mandate mango mansion manual maple marble march margin marine market marriage mask mass master match material math matrix matter maximum maze meadow mean measure meat mechanic medal media melody melt member memory mention menu mercy merge merit merry mesh message metal method middle midnight milk million mimic mind minimum minor minute miracle mirror misery miss mistake mix mixed mixture mobile model modify mom moment monitor monkey monster month moon moral more morning mosquito mother motion motor mountain mouse move movie much muffin mule multiply muscle museum mushroom music must mutual myself mystery myth naive name napkin narrow nasty nation nature near neck need negative neglect neither nephew nerve nest net network neutral never news next nice night noble noise nominee noodle normal north nose notable note nothing notice novel now nuclear number nurse nut oak obey object oblige obscure observe obtain obvious occur ocean october odor off offer office often oil okay old olive olympic omit once one onion online only open opera opinion oppose option orange orbit orchard order ordinary organ orient original orphan ostrich other outdoor outer output outside oval oven over own owner oxygen oyster ozone pact paddle page pair palace palm panda panel panic panther paper parade parent park parrot party pass patch path patient patrol pattern pause pave payment peace peanut pear peasant pelican pen penalty pencil people pepper perfect permit person pet phone photo phrase physical piano picnic picture piece pig pigeon pill pilot pink pioneer pipe pistol pitch pizza place planet plastic plate play please pledge pluck plug plunge poem poet point polar pole police pond pony pool popular portion position possible post potato pottery poverty powder power practice praise predict prefer prepare present pretty prevent price pride primary print priority prison private prize problem process produce profit program project promote proof property prosper protect proud provide public pudding pull pulp pulse pumpkin punch pupil puppy purchase purity purpose purse push put puzzle pyramid quality quantum quarter question quick quit quiz quote rabbit raccoon race rack radar radio rail rain raise rally ramp ranch random range rapid rare rate rather raven raw razor ready real reason rebel rebuild recall receive recipe record recycle reduce reflect reform refuse region regret regular reject relax release relief rely remain remember remind remove render renew rent reopen repair repeat replace report require rescue resemble resist resource response result retire retreat return reunion reveal review reward rhythm rib ribbon rice rich ride ridge rifle right rigid ring riot ripple risk ritual rival river road roast robot robust rocket romance roof rookie room rose rotate rough round route royal rubber rude rug rule run runway rural sad saddle sadness safe sail salad salmon salon salt salute same sample sand satisfy satoshi sauce sausage save say scale scan scare scatter scene scheme school science scissors scorpion scout scrap screen script scrub sea search season seat second secret section security seed seek segment select sell seminar senior sense sentence series service session settle setup seven shadow shaft shallow share shed shell sheriff shield shift shine ship shiver shock shoe shoot shop short shoulder shove shrimp shrug shuffle shy sibling sick side siege sight sign silent silk silly silver similar simple since sing siren sister situate six size skate sketch ski skill skin skirt skull slab slam sleep slender slice slide slight slim slogan slot slow slush small smart smile smoke smooth snack snake snap sniff snow soap soccer social sock soda soft solar soldier solid solution solve someone song soon sorry sort soul sound soup source south space spare spatial spawn speak special speed spell spend sphere spice spider spike spin spirit split spoil sponsor spoon sport spot spray spread spring spy square squeeze squirrel stable stadium staff stage stairs stamp stand start state stay steak steel stem step stereo stick still sting stock stomach stone stool story stove strategy street strike strong struggle student stuff stumble style subject submit subway success such sudden suffer sugar suggest suit summer sun sunny sunset super supply supreme sure surface surge surprise surround survey suspect sustain swallow swamp swap swarm swear sweet swift swim swing switch sword symbol symptom syrup system table tackle tag tail talent talk tank tape target task taste tattoo taxi teach team tell ten tenant tennis tent term test text thank that theme then theory there they thing this thought three thrive throw thumb thunder ticket tide tiger tilt timber time tiny tip tired tissue title toast tobacco today toddler toe together toilet token tomato tomorrow tone tongue tonight tool tooth top topic topple torch tornado tortoise toss total tourist toward tower town toy track trade traffic tragic train transfer trap trash travel tray treat tree trend trial tribe trick trigger trim trip trophy trouble truck true truly trumpet trust truth try tube tuition tumble tuna tunnel turkey turn turtle twelve twenty twice twin twist two type typical ugly umbrella unable unaware uncle uncover under undo unfair unfold unhappy uniform unique unit universe unknown unlock until unusual unveil update upgrade uphold upon upper upset urban urge usage use used useful useless usual utility vacant vacuum vague valid valley valve van vanish vapor various vast vault vehicle velvet vendor venture venue verb verify version very vessel veteran viable vibrant vicious victory video view village vintage violin virtual virus visa visit visual vital vivid vocal voice void volcano volume vote voyage wage wagon wait walk wall walnut want warfare warm warrior wash wasp waste water wave way wealth weapon wear weasel weather web wedding weekend weird welcome west wet whale what wheat wheel when where whip whisper wide width wife wild will win window wine wing wink winner winter wire wisdom wise wish witness wolf woman wonder wood wool word work world worry worth wrap wreck wrestle wrist write wrong yard year yellow you young youth zebra zero zone zoo)
declare -a czech=(abdikace abeceda adresa agrese akce aktovka alej alkohol amputace ananas andulka anekdota anketa antika anulovat archa arogance asfalt asistent aspirace astma astronom atlas atletika atol autobus azyl babka bachor bacil baculka badatel bageta bagr bahno bakterie balada baletka balkon balonek balvan balza bambus bankomat barbar baret barman baroko barva baterka batoh bavlna bazalka bazilika bazuka bedna beran beseda bestie beton bezinka bezmoc beztak bicykl bidlo biftek bikiny bilance biograf biolog bitva bizon blahobyt blatouch blecha bledule blesk blikat blizna blokovat bloudit blud bobek bobr bodlina bodnout bohatost bojkot bojovat bokorys bolest borec borovice bota boubel bouchat bouda boule bourat boxer bradavka brambora branka bratr brepta briketa brko brloh bronz broskev brunetka brusinka brzda brzy bublina bubnovat buchta buditel budka budova bufet bujarost bukvice buldok bulva bunda bunkr burza butik buvol buzola bydlet bylina bytovka bzukot capart carevna cedr cedule cejch cejn cela celer celkem celnice cenina cennost cenovka centrum cenzor cestopis cetka chalupa chapadlo charita chata chechtat chemie chichot chirurg chlad chleba chlubit chmel chmura chobot chochol chodba cholera chomout chopit choroba chov chrapot chrlit chrt chrup chtivost chudina chutnat chvat chvilka chvost chyba chystat chytit cibule cigareta cihelna cihla cinkot cirkus cisterna citace citrus cizinec cizost clona cokoliv couvat ctitel ctnost cudnost cuketa cukr cupot cvaknout cval cvik cvrkot cyklista daleko dareba datel datum dcera debata dechovka decibel deficit deflace dekl dekret demokrat deprese derby deska detektiv dikobraz diktovat dioda diplom disk displej divadlo divoch dlaha dlouho dluhopis dnes dobro dobytek docent dochutit dodnes dohled dohoda dohra dojem dojnice doklad dokola doktor dokument dolar doleva dolina doma dominant domluvit domov donutit dopad dopis doplnit doposud doprovod dopustit dorazit dorost dort dosah doslov dostatek dosud dosyta dotaz dotek dotknout doufat doutnat dovozce dozadu doznat dozorce drahota drak dramatik dravec draze drdol drobnost drogerie drozd drsnost drtit drzost duben duchovno dudek duha duhovka dusit dusno dutost dvojice dvorec dynamit ekolog ekonomie elektron elipsa email emise emoce empatie epizoda epocha epopej epos esej esence eskorta eskymo etiketa euforie evoluce exekuce exkurze expedice exploze export extrakt facka fajfka fakulta fanatik fantazie farmacie favorit fazole federace fejeton fenka fialka figurant filozof filtr finance finta fixace fjord flanel flirt flotila fond fosfor fotbal fotka foton frakce freska fronta fukar funkce fyzika galeje garant genetika geolog gilotina glazura glejt golem golfista gotika graf gramofon granule grep gril grog groteska guma hadice hadr hala halenka hanba hanopis harfa harpuna havran hebkost hejkal hejno hejtman hektar helma hematom herec herna heslo hezky historik hladovka hlasivky hlava hledat hlen hlodavec hloh hloupost hltat hlubina hluchota hmat hmota hmyz hnis hnojivo hnout hoblina hoboj hoch hodiny hodlat hodnota hodovat hojnost hokej holinka holka holub homole honitba honorace horal horda horizont horko horlivec hormon hornina horoskop horstvo hospoda hostina hotovost houba houf houpat houska hovor hradba hranice hravost hrazda hrbolek hrdina hrdlo hrdost hrnek hrobka hromada hrot hrouda hrozen hrstka hrubost hryzat hubenost hubnout hudba hukot humr husita hustota hvozd hybnost hydrant hygiena hymna hysterik idylka ihned ikona iluze imunita infekce inflace inkaso inovace inspekce internet invalida investor inzerce ironie jablko jachta jahoda jakmile jakost jalovec jantar jarmark jaro jasan jasno jatka javor jazyk jedinec jedle jednatel jehlan jekot jelen jelito jemnost jenom jepice jeseter jevit jezdec jezero jinak jindy jinoch jiskra jistota jitrnice jizva jmenovat jogurt jurta kabaret kabel kabinet kachna kadet kadidlo kahan kajak kajuta kakao kaktus kalamita kalhoty kalibr kalnost kamera kamkoliv kamna kanibal kanoe kantor kapalina kapela kapitola kapka kaple kapota kapr kapusta kapybara karamel karotka karton kasa katalog katedra kauce kauza kavalec kazajka kazeta kazivost kdekoliv kdesi kedluben kemp keramika kino klacek kladivo klam klapot klasika klaun klec klenba klepat klesnout klid klima klisna klobouk klokan klopa kloub klubovna klusat kluzkost kmen kmitat kmotr kniha knot koalice koberec kobka kobliha kobyla kocour kohout kojenec kokos koktejl kolaps koleda kolize kolo komando kometa komik komnata komora kompas komunita konat koncept kondice konec konfese kongres konina konkurs kontakt konzerva kopanec kopie kopnout koprovka korbel korektor kormidlo koroptev korpus koruna koryto korzet kosatec kostka kotel kotleta kotoul koukat koupelna kousek kouzlo kovboj koza kozoroh krabice krach krajina kralovat krasopis kravata kredit krejcar kresba kreveta kriket kritik krize krkavec krmelec krmivo krocan krok kronika kropit kroupa krovka krtek kruhadlo krupice krutost krvinka krychle krypta krystal kryt kudlanka kufr kujnost kukla kulajda kulich kulka kulomet kultura kuna kupodivu kurt kurzor kutil kvalita kvasinka kvestor kynolog kyselina kytara kytice kytka kytovec kyvadlo labrador lachtan ladnost laik lakomec lamela lampa lanovka lasice laso lastura latinka lavina lebka leckdy leden lednice ledovka ledvina legenda legie legrace lehce lehkost lehnout lektvar lenochod lentilka lepenka lepidlo letadlo letec letmo letokruh levhart levitace levobok libra lichotka lidojed lidskost lihovina lijavec lilek limetka linie linka linoleum listopad litina litovat lobista lodivod logika logoped lokalita loket lomcovat lopata lopuch lord losos lotr loudal louh louka louskat lovec lstivost lucerna lucifer lump lusk lustrace lvice lyra lyrika lysina madam madlo magistr mahagon majetek majitel majorita makak makovice makrela malba malina malovat malvice maminka mandle manko marnost masakr maskot masopust matice matrika maturita mazanec mazivo mazlit mazurka mdloba mechanik meditace medovina melasa meloun mentolka metla metoda metr mezera migrace mihnout mihule mikina mikrofon milenec milimetr milost mimika mincovna minibar minomet minulost miska mistr mixovat mladost mlha mlhovina mlok mlsat mluvit mnich mnohem mobil mocnost modelka modlitba mohyla mokro molekula momentka monarcha monokl monstrum montovat monzun mosaz moskyt most motivace motorka motyka moucha moudrost mozaika mozek mozol mramor mravenec mrkev mrtvola mrzet mrzutost mstitel mudrc muflon mulat mumie munice muset mutace muzeum muzikant myslivec mzda nabourat nachytat nadace nadbytek nadhoz nadobro nadpis nahlas nahnat nahodile nahradit naivita najednou najisto najmout naklonit nakonec nakrmit nalevo namazat namluvit nanometr naoko naopak naostro napadat napevno naplnit napnout naposled naprosto narodit naruby narychlo nasadit nasekat naslepo nastat natolik navenek navrch navzdory nazvat nebe nechat necky nedaleko nedbat neduh negace nehet nehoda nejen nejprve neklid nelibost nemilost nemoc neochota neonka nepokoj nerost nerv nesmysl nesoulad netvor neuron nevina nezvykle nicota nijak nikam nikdy nikl nikterak nitro nocleh nohavice nominace nora norek nositel nosnost nouze noviny novota nozdra nuda nudle nuget nutit nutnost nutrie nymfa obal obarvit obava obdiv obec obehnat obejmout obezita obhajoba obilnice objasnit objekt obklopit oblast oblek obliba obloha obluda obnos obohatit obojek obout obrazec obrna obruba obrys obsah obsluha obstarat obuv obvaz obvinit obvod obvykle obyvatel obzor ocas ocel ocenit ochladit ochota ochrana ocitnout odboj odbyt odchod odcizit odebrat odeslat odevzdat odezva odhadce odhodit odjet odjinud odkaz odkoupit odliv odluka odmlka odolnost odpad odpis odplout odpor odpustit odpykat odrazka odsoudit odstup odsun odtok odtud odvaha odveta odvolat odvracet odznak ofina ofsajd ohlas ohnisko ohrada ohrozit ohryzek okap okenice oklika okno okouzlit okovy okrasa okres okrsek okruh okupant okurka okusit olejnina olizovat omak omeleta omezit omladina omlouvat omluva omyl onehdy opakovat opasek operace opice opilost opisovat opora opozice opravdu oproti orbital orchestr orgie orlice orloj ortel osada oschnout osika osivo oslava oslepit oslnit oslovit osnova osoba osolit ospalec osten ostraha ostuda ostych osvojit oteplit otisk otop otrhat otrlost otrok otruby otvor ovanout ovar oves ovlivnit ovoce oxid ozdoba pachatel pacient padouch pahorek pakt palanda palec palivo paluba pamflet pamlsek panenka panika panna panovat panstvo pantofle paprika parketa parodie parta paruka paryba paseka pasivita pastelka patent patrona pavouk pazneht pazourek pecka pedagog pejsek peklo peloton penalta pendrek penze periskop pero pestrost petarda petice petrolej pevnina pexeso pianista piha pijavice pikle piknik pilina pilnost pilulka pinzeta pipeta pisatel pistole pitevna pivnice pivovar placenta plakat plamen planeta plastika platit plavidlo plaz plech plemeno plenta ples pletivo plevel plivat plnit plno plocha plodina plomba plout pluk plyn pobavit pobyt pochod pocit poctivec podat podcenit podepsat podhled podivit podklad podmanit podnik podoba podpora podraz podstata podvod podzim poezie pohanka pohnutka pohovor pohroma pohyb pointa pojistka pojmout pokazit pokles pokoj pokrok pokuta pokyn poledne polibek polknout poloha polynom pomalu pominout pomlka pomoc pomsta pomyslet ponechat ponorka ponurost popadat popel popisek poplach poprosit popsat popud poradce porce porod porucha poryv posadit posed posila poskok poslanec posoudit pospolu postava posudek posyp potah potkan potlesk potomek potrava potupa potvora poukaz pouto pouzdro povaha povidla povlak povoz povrch povstat povyk povzdech pozdrav pozemek poznatek pozor pozvat pracovat prahory praktika prales praotec praporek prase pravda princip prkno probudit procento prodej profese prohra projekt prolomit promile pronikat propad prorok prosba proton proutek provaz prskavka prsten prudkost prut prvek prvohory psanec psovod pstruh ptactvo puberta puch pudl pukavec puklina pukrle pult pumpa punc pupen pusa pusinka pustina putovat putyka pyramida pysk pytel racek rachot radiace radnice radon raft ragby raketa rakovina rameno rampouch rande rarach rarita rasovna rastr ratolest razance razidlo reagovat reakce recept redaktor referent reflex rejnok reklama rekord rekrut rektor reputace revize revma revolver rezerva riskovat riziko robotika rodokmen rohovka rokle rokoko romaneto ropovod ropucha rorejs rosol rostlina rotmistr rotoped rotunda roubenka roucho roup roura rovina rovnice rozbor rozchod rozdat rozeznat rozhodce rozinka rozjezd rozkaz rozloha rozmar rozpad rozruch rozsah roztok rozum rozvod rubrika ruchadlo rukavice rukopis ryba rybolov rychlost rydlo rypadlo rytina ryzost sadista sahat sako samec samizdat samota sanitka sardinka sasanka satelit sazba sazenice sbor schovat sebranka secese sedadlo sediment sedlo sehnat sejmout sekera sekta sekunda sekvoje semeno seno servis sesadit seshora seskok seslat sestra sesuv sesypat setba setina setkat setnout setrvat sever seznam shoda shrnout sifon silnice sirka sirotek sirup situace skafandr skalisko skanzen skaut skeptik skica skladba sklenice sklo skluz skoba skokan skoro skripta skrz skupina skvost skvrna slabika sladidlo slanina slast slavnost sledovat slepec sleva slezina slib slina sliznice slon sloupek slovo sluch sluha slunce slupka slza smaragd smetana smilstvo smlouva smog smrad smrk smrtka smutek smysl snad snaha snob sobota socha sodovka sokol sopka sotva souboj soucit soudce souhlas soulad soumrak souprava soused soutok souviset spalovna spasitel spis splav spodek spojenec spolu sponzor spornost spousta sprcha spustit sranda sraz srdce srna srnec srovnat srpen srst srub stanice starosta statika stavba stehno stezka stodola stolek stopa storno stoupat strach stres strhnout strom struna studna stupnice stvol styk subjekt subtropy suchar sudost sukno sundat sunout surikata surovina svah svalstvo svetr svatba svazek svisle svitek svoboda svodidlo svorka svrab sykavka sykot synek synovec sypat sypkost syrovost sysel sytost tabletka tabule tahoun tajemno tajfun tajga tajit tajnost taktika tamhle tampon tancovat tanec tanker tapeta tavenina tazatel technika tehdy tekutina telefon temnota tendence tenista tenor teplota tepna teprve terapie termoska textil ticho tiskopis titulek tkadlec tkanina tlapka tleskat tlukot tlupa tmel toaleta topinka topol torzo touha toulec tradice traktor tramp trasa traverza trefit trest trezor trhavina trhlina trochu trojice troska trouba trpce trpitel trpkost trubec truchlit truhlice trus trvat tudy tuhnout tuhost tundra turista turnaj tuzemsko tvaroh tvorba tvrdost tvrz tygr tykev ubohost uboze ubrat ubrousek ubrus ubytovna ucho uctivost udivit uhradit ujednat ujistit ujmout ukazatel uklidnit uklonit ukotvit ukrojit ulice ulita ulovit umyvadlo unavit uniforma uniknout upadnout uplatnit uplynout upoutat upravit uran urazit usednout usilovat usmrtit usnadnit usnout usoudit ustlat ustrnout utahovat utkat utlumit utonout utopenec utrousit uvalit uvolnit uvozovka uzdravit uzel uzenina uzlina uznat vagon valcha valoun vana vandal vanilka varan varhany varovat vcelku vchod vdova vedro vegetace vejce velbloud veletrh velitel velmoc velryba venkov veranda verze veselka veskrze vesnice vespodu vesta veterina veverka vibrace vichr videohra vidina vidle vila vinice viset vitalita vize vizitka vjezd vklad vkus vlajka vlak vlasec vlevo vlhkost vliv vlnovka vloupat vnucovat vnuk voda vodivost vodoznak vodstvo vojensky vojna vojsko volant volba volit volno voskovka vozidlo vozovna vpravo vrabec vracet vrah vrata vrba vrcholek vrhat vrstva vrtule vsadit vstoupit vstup vtip vybavit vybrat vychovat vydat vydra vyfotit vyhledat vyhnout vyhodit vyhradit vyhubit vyjasnit vyjet vyjmout vyklopit vykonat vylekat vymazat vymezit vymizet vymyslet vynechat vynikat vynutit vypadat vyplatit vypravit vypustit vyrazit vyrovnat vyrvat vyslovit vysoko vystavit vysunout vysypat vytasit vytesat vytratit vyvinout vyvolat vyvrhel vyzdobit vyznat vzadu vzbudit vzchopit vzdor vzduch vzdychat vzestup vzhledem vzkaz vzlykat vznik vzorek vzpoura vztah vztek xylofon zabrat zabydlet zachovat zadarmo zadusit zafoukat zahltit zahodit zahrada zahynout zajatec zajet zajistit zaklepat zakoupit zalepit zamezit zamotat zamyslet zanechat zanikat zaplatit zapojit zapsat zarazit zastavit zasunout zatajit zatemnit zatknout zaujmout zavalit zavelet zavinit zavolat zavrtat zazvonit zbavit zbrusu zbudovat zbytek zdaleka zdarma zdatnost zdivo zdobit zdroj zdvih zdymadlo zelenina zeman zemina zeptat zezadu zezdola zhatit zhltnout zhluboka zhotovit zhruba zima zimnice zjemnit zklamat zkoumat zkratka zkumavka zlato zlehka zloba zlom zlost zlozvyk zmapovat zmar zmatek zmije zmizet zmocnit zmodrat zmrzlina zmutovat znak znalost znamenat znovu zobrazit zotavit zoubek zoufale zplodit zpomalit zprava zprostit zprudka zprvu zrada zranit zrcadlo zrnitost zrno zrovna zrychlit zrzavost zticha ztratit zubovina zubr zvednout zvenku zvesela zvon zvrat zvukovod zvyk)
declare -a italian=(abaco abbaglio abbinato abete abisso abolire abrasivo abrogato accadere accenno accusato acetone achille acido acqua acre acrilico acrobata acuto adagio addebito addome adeguato aderire adipe adottare adulare affabile affetto affisso affranto aforisma afoso africano agave agente agevole aggancio agire agitare agonismo agricolo agrumeto aguzzo alabarda alato albatro alberato albo albume alce alcolico alettone alfa algebra aliante alibi alimento allagato allegro allievo allodola allusivo almeno alogeno alpaca alpestre altalena alterno alticcio altrove alunno alveolo alzare amalgama amanita amarena ambito ambrato ameba america ametista amico ammasso ammenda ammirare ammonito amore ampio ampliare amuleto anacardo anagrafe analista anarchia anatra anca ancella ancora andare andrea anello angelo angolare angusto anima annegare annidato anno annuncio anonimo anticipo anzi apatico apertura apode apparire appetito appoggio approdo appunto aprile arabica arachide aragosta araldica arancio aratura arazzo arbitro archivio ardito arenile argento argine arguto aria armonia arnese arredato arringa arrosto arsenico arso artefice arzillo asciutto ascolto asepsi asettico asfalto asino asola aspirato aspro assaggio asse assoluto assurdo asta astenuto astice astratto atavico ateismo atomico atono attesa attivare attorno attrito attuale ausilio austria autista autonomo autunno avanzato avere avvenire avviso avvolgere azione azoto azzimo azzurro babele baccano bacino baco badessa badilata bagnato baita balcone baldo balena ballata balzano bambino bandire baraonda barbaro barca baritono barlume barocco basilico basso batosta battuto baule bava bavosa becco beffa belgio belva benda benevole benigno benzina bere berlina beta bibita bici bidone bifido biga bilancia bimbo binocolo biologo bipede bipolare birbante birra biscotto bisesto bisnonno bisonte bisturi bizzarro blando blatta bollito bonifico bordo bosco botanico bottino bozzolo braccio bradipo brama branca bravura bretella brevetto brezza briglia brillante brindare broccolo brodo bronzina brullo bruno bubbone buca budino buffone buio bulbo buono burlone burrasca bussola busta cadetto caduco calamaro calcolo calesse calibro calmo caloria cambusa camerata camicia cammino camola campale canapa candela cane canino canotto cantina capace capello capitolo capogiro cappero capra capsula carapace carcassa cardo carisma carovana carretto cartolina casaccio cascata caserma caso cassone castello casuale catasta catena catrame cauto cavillo cedibile cedrata cefalo celebre cellulare cena cenone centesimo ceramica cercare certo cerume cervello cesoia cespo ceto chela chiaro chicca chiedere chimera china chirurgo chitarra ciao ciclismo cifrare cigno cilindro ciottolo circa cirrosi citrico cittadino ciuffo civetta civile classico clinica cloro cocco codardo codice coerente cognome collare colmato colore colposo coltivato colza coma cometa commando comodo computer comune conciso condurre conferma congelare coniuge connesso conoscere consumo continuo convegno coperto copione coppia copricapo corazza cordata coricato cornice corolla corpo corredo corsia cortese cosmico costante cottura covato cratere cravatta creato credere cremoso crescita creta criceto crinale crisi critico croce cronaca crostata cruciale crusca cucire cuculo cugino cullato cupola curatore cursore curvo cuscino custode dado daino dalmata damerino daniela dannoso danzare datato davanti davvero debutto decennio deciso declino decollo decreto dedicato definito deforme degno delegare delfino delirio delta demenza denotato dentro deposito derapata derivare deroga descritto deserto desiderio desumere detersivo devoto diametro dicembre diedro difeso diffuso digerire digitale diluvio dinamico dinnanzi dipinto diploma dipolo diradare dire dirotto dirupo disagio discreto disfare disgelo disposto distanza disumano dito divano divelto dividere divorato doblone docente doganale dogma dolce domato domenica dominare dondolo dono dormire dote dottore dovuto dozzina drago druido dubbio dubitare ducale duna duomo duplice duraturo ebano eccesso ecco eclissi economia edera edicola edile editoria educare egemonia egli egoismo egregio elaborato elargire elegante elencato eletto elevare elfico elica elmo elsa eluso emanato emblema emesso emiro emotivo emozione empirico emulo endemico enduro energia enfasi enoteca entrare enzima epatite epilogo episodio epocale eppure equatore erario erba erboso erede eremita erigere ermetico eroe erosivo errante esagono esame esanime esaudire esca esempio esercito esibito esigente esistere esito esofago esortato esoso espanso espresso essenza esso esteso estimare estonia estroso esultare etilico etnico etrusco etto euclideo europa evaso evidenza evitato evoluto evviva fabbrica faccenda fachiro falco famiglia fanale fanfara fango fantasma fare farfalla farinoso farmaco fascia fastoso fasullo faticare fato favoloso febbre fecola fede fegato felpa feltro femmina fendere fenomeno fermento ferro fertile fessura festivo fetta feudo fiaba fiducia fifa figurato filo finanza finestra finire fiore fiscale fisico fiume flacone flamenco flebo flemma florido fluente fluoro fobico focaccia focoso foderato foglio folata folclore folgore fondente fonetico fonia fontana forbito forchetta foresta formica fornaio foro fortezza forzare fosfato fosso fracasso frana frassino fratello freccetta frenata fresco frigo frollino fronde frugale frutta fucilata fucsia fuggente fulmine fulvo fumante fumetto fumoso fune funzione fuoco furbo furgone furore fuso futile gabbiano gaffe galateo gallina galoppo gambero gamma garanzia garbo garofano garzone gasdotto gasolio gastrico gatto gaudio gazebo gazzella geco gelatina gelso gemello gemmato gene genitore gennaio genotipo gergo ghepardo ghiaccio ghisa giallo gilda ginepro giocare gioiello giorno giove girato girone gittata giudizio giurato giusto globulo glutine gnomo gobba golf gomito gommone gonfio gonna governo gracile grado grafico grammo grande grattare gravoso grazia greca gregge grifone grigio grinza grotta gruppo guadagno guaio guanto guardare gufo guidare ibernato icona identico idillio idolo idra idrico idrogeno igiene ignaro ignorato ilare illeso illogico illudere imballo imbevuto imbocco imbuto immane immerso immolato impacco impeto impiego importo impronta inalare inarcare inattivo incanto incendio inchino incisivo incluso incontro incrocio incubo indagine india indole inedito infatti infilare inflitto ingaggio ingegno inglese ingordo ingrosso innesco inodore inoltrare inondato insano insetto insieme insonnia insulina intasato intero intonaco intuito inumidire invalido invece invito iperbole ipnotico ipotesi ippica iride irlanda ironico irrigato irrorare isolato isotopo isterico istituto istrice italia iterare labbro labirinto lacca lacerato lacrima lacuna laddove lago lampo lancetta lanterna lardoso larga laringe lastra latenza latino lattuga lavagna lavoro legale leggero lembo lentezza lenza leone lepre lesivo lessato lesto letterale leva levigato libero lido lievito lilla limatura limitare limpido lineare lingua liquido lira lirica lisca lite litigio livrea locanda lode logica lombare londra longevo loquace lorenzo loto lotteria luce lucidato lumaca luminoso lungo lupo luppolo lusinga lusso lutto macabro macchina macero macinato madama magico maglia magnete magro maiolica malafede malgrado malinteso malsano malto malumore mana mancia mandorla mangiare manifesto mannaro manovra mansarda mantide manubrio mappa maratona marcire maretta marmo marsupio maschera massaia mastino materasso matricola mattone maturo mazurca meandro meccanico mecenate medesimo meditare mega melassa melis melodia meninge meno mensola mercurio merenda merlo meschino mese messere mestolo metallo metodo mettere miagolare mica micelio michele microbo midollo miele migliore milano milite mimosa minerale mini minore mirino mirtillo miscela missiva misto misurare mitezza mitigare mitra mittente mnemonico modello modifica modulo mogano mogio mole molosso monastero monco mondina monetario monile monotono monsone montato monviso mora mordere morsicato mostro motivato motosega motto movenza movimento mozzo mucca mucosa muffa mughetto mugnaio mulatto mulinello multiplo mummia munto muovere murale musa muscolo musica mutevole muto nababbo nafta nanometro narciso narice narrato nascere nastrare naturale nautica naviglio nebulosa necrosi negativo negozio nemmeno neofita neretto nervo nessuno nettuno neutrale neve nevrotico nicchia ninfa nitido nobile nocivo nodo nome nomina nordico normale norvegese nostrano notare notizia notturno novella nucleo nulla numero nuovo nutrire nuvola nuziale oasi obbedire obbligo obelisco oblio obolo obsoleto occasione occhio occidente occorrere occultare ocra oculato odierno odorare offerta offrire offuscato oggetto oggi ognuno olandese olfatto oliato oliva ologramma oltre omaggio ombelico ombra omega omissione ondoso onere onice onnivoro onorevole onta operato opinione opposto oracolo orafo ordine orecchino orefice orfano organico origine orizzonte orma ormeggio ornativo orologio orrendo orribile ortensia ortica orzata orzo osare oscurare osmosi ospedale ospite ossa ossidare ostacolo oste otite otre ottagono ottimo ottobre ovale ovest ovino oviparo ovocito ovunque ovviare ozio pacchetto pace pacifico padella padrone paese paga pagina palazzina palesare pallido palo palude pandoro pannello paolo paonazzo paprica parabola parcella parere pargolo pari parlato parola partire parvenza parziale passivo pasticca patacca patologia pattume pavone peccato pedalare pedonale peggio peloso penare pendice penisola pennuto penombra pensare pentola pepe pepita perbene percorso perdonato perforare pergamena periodo permesso perno perplesso persuaso pertugio pervaso pesatore pesista peso pestifero petalo pettine petulante pezzo piacere pianta piattino piccino picozza piega pietra piffero pigiama pigolio pigro pila pilifero pillola pilota pimpante pineta pinna pinolo pioggia piombo piramide piretico pirite pirolisi pitone pizzico placebo planare plasma platano plenario pochezza poderoso podismo poesia poggiare polenta poligono pollice polmonite polpetta polso poltrona polvere pomice pomodoro ponte popoloso porfido poroso porpora porre portata posa positivo possesso postulato potassio potere pranzo prassi pratica precluso predica prefisso pregiato prelievo premere prenotare preparato presenza pretesto prevalso prima principe privato problema procura produrre profumo progetto prolunga promessa pronome proposta proroga proteso prova prudente prugna prurito psiche pubblico pudica pugilato pugno pulce pulito pulsante puntare pupazzo pupilla puro quadro qualcosa quasi querela quota raccolto raddoppio radicale radunato raffica ragazzo ragione ragno ramarro ramingo ramo randagio rantolare rapato rapina rappreso rasatura raschiato rasente rassegna rastrello rata ravveduto reale recepire recinto recluta recondito recupero reddito redimere regalato registro regola regresso relazione remare remoto renna replica reprimere reputare resa residente responso restauro rete retina retorica rettifica revocato riassunto ribadire ribelle ribrezzo ricarica ricco ricevere riciclato ricordo ricreduto ridicolo ridurre rifasare riflesso riforma rifugio rigare rigettato righello rilassato rilevato rimanere rimbalzo rimedio rimorchio rinascita rincaro rinforzo rinnovo rinomato rinsavito rintocco rinuncia rinvenire riparato ripetuto ripieno riportare ripresa ripulire risata rischio riserva risibile riso rispetto ristoro risultato risvolto ritardo ritegno ritmico ritrovo riunione riva riverso rivincita rivolto rizoma roba robotico robusto roccia roco rodaggio rodere roditore rogito rollio romantico rompere ronzio rosolare rospo rotante rotondo rotula rovescio rubizzo rubrica ruga rullino rumine rumoroso ruolo rupe russare rustico sabato sabbiare sabotato sagoma salasso saldatura salgemma salivare salmone salone saltare saluto salvo sapere sapido saporito saraceno sarcasmo sarto sassoso satellite satira satollo saturno savana savio saziato sbadiglio sbalzo sbancato sbarra sbattere sbavare sbendare sbirciare sbloccato sbocciato sbrinare sbruffone sbuffare scabroso scadenza scala scambiare scandalo scapola scarso scatenare scavato scelto scenico scettro scheda schiena sciarpa scienza scindere scippo sciroppo scivolo sclerare scodella scolpito scomparto sconforto scoprire scorta scossone scozzese scriba scrollare scrutinio scuderia scultore scuola scuro scusare sdebitare sdoganare seccatura secondo sedano seggiola segnalato segregato seguito selciato selettivo sella selvaggio semaforo sembrare seme seminato sempre senso sentire sepolto sequenza serata serbato sereno serio serpente serraglio servire sestina setola settimana sfacelo sfaldare sfamato sfarzoso sfaticato sfera sfida sfilato sfinge sfocato sfoderare sfogo sfoltire sforzato sfratto sfruttato sfuggito sfumare sfuso sgabello sgarbato sgonfiare sgorbio sgrassato sguardo sibilo siccome sierra sigla signore silenzio sillaba simbolo simpatico simulato sinfonia singolo sinistro sino sintesi sinusoide sipario sisma sistole situato slitta slogatura sloveno smarrito smemorato smentito smeraldo smilzo smontare smottato smussato snellire snervato snodo sobbalzo sobrio soccorso sociale sodale soffitto sogno soldato solenne solido sollazzo solo solubile solvente somatico somma sonda sonetto sonnifero sopire soppeso sopra sorgere sorpasso sorriso sorso sorteggio sorvolato sospiro sosta sottile spada spalla spargere spatola spavento spazzola specie spedire spegnere spelatura speranza spessore spettrale spezzato spia spigoloso spillato spinoso spirale splendido sportivo sposo spranga sprecare spronato spruzzo spuntino squillo sradicare srotolato stabile stacco staffa stagnare stampato stantio starnuto stasera statuto stelo steppa sterzo stiletto stima stirpe stivale stizzoso stonato storico strappo stregato stridulo strozzare strutto stuccare stufo stupendo subentro succoso sudore suggerito sugo sultano suonare superbo supporto surgelato surrogato sussurro sutura svagare svedese sveglio svelare svenuto svezia sviluppo svista svizzera svolta svuotare tabacco tabulato tacciare taciturno tale talismano tampone tannino tara tardivo targato tariffa tarpare tartaruga tasto tattico taverna tavolata tazza teca tecnico telefono temerario tempo temuto tendone tenero tensione tentacolo teorema terme terrazzo terzetto tesi tesserato testato tetro tettoia tifare tigella timbro tinto tipico tipografo tiraggio tiro titanio titolo titubante tizio tizzone toccare tollerare tolto tombola tomo tonfo tonsilla topazio topologia toppa torba tornare torrone tortora toscano tossire tostatura totano trabocco trachea trafila tragedia tralcio tramonto transito trapano trarre trasloco trattato trave treccia tremolio trespolo tributo tricheco trifoglio trillo trincea trio tristezza triturato trivella tromba trono troppo trottola trovare truccato tubatura tuffato tulipano tumulto tunisia turbare turchino tuta tutela ubicato uccello uccisore udire uditivo uffa ufficio uguale ulisse ultimato umano umile umorismo uncinetto ungere ungherese unicorno unificato unisono unitario unte uovo upupa uragano urgenza urlo usanza usato uscito usignolo usuraio utensile utilizzo utopia vacante vaccinato vagabondo vagliato valanga valgo valico valletta valoroso valutare valvola vampata vangare vanitoso vano vantaggio vanvera vapore varano varcato variante vasca vedetta vedova veduto vegetale veicolo velcro velina velluto veloce venato vendemmia vento verace verbale vergogna verifica vero verruca verticale vescica vessillo vestale veterano vetrina vetusto viandante vibrante vicenda vichingo vicinanza vidimare vigilia vigneto vigore vile villano vimini vincitore viola vipera virgola virologo virulento viscoso visione vispo vissuto visura vita vitello vittima vivanda vivido viziare voce voga volatile volere volpe voragine vulcano zampogna zanna zappato zattera zavorra zefiro zelante zelo zenzero zerbino zibetto zinco zircone zitto zolla zotico zucchero zufolo zulu zuppa)
declare -a korean=(가격 가끔 가난 가능 가득 가르침 가뭄 가방 가상 가슴 가운데 가을 가이드 가입 가장 가정 가족 가죽 각오 각자 간격 간부 간섭 간장 간접 간판 갈등 갈비 갈색 갈증 감각 감기 감소 감수성 감자 감정 갑자기 강남 강당 강도 강력히 강변 강북 강사 강수량 강아지 강원도 강의 강제 강조 같이 개구리 개나리 개방 개별 개선 개성 개인 객관적 거실 거액 거울 거짓 거품 걱정 건강 건물 건설 건조 건축 걸음 검사 검토 게시판 게임 겨울 견해 결과 결국 결론 결석 결승 결심 결정 결혼 경계 경고 경기 경력 경복궁 경비 경상도 경영 경우 경쟁 경제 경주 경찰 경치 경향 경험 계곡 계단 계란 계산 계속 계약 계절 계층 계획 고객 고구려 고궁 고급 고등학생 고무신 고민 고양이 고장 고전 고집 고춧가루 고통 고향 곡식 골목 골짜기 골프 공간 공개 공격 공군 공급 공기 공동 공무원 공부 공사 공식 공업 공연 공원 공장 공짜 공책 공통 공포 공항 공휴일 과목 과일 과장 과정 과학 관객 관계 관광 관념 관람 관련 관리 관습 관심 관점 관찰 광경 광고 광장 광주 괴로움 굉장히 교과서 교문 교복 교실 교양 교육 교장 교직 교통 교환 교훈 구경 구름 구멍 구별 구분 구석 구성 구속 구역 구입 구청 구체적 국가 국기 국내 국립 국물 국민 국수 국어 국왕 국적 국제 국회 군대 군사 군인 궁극적 권리 권위 권투 귀국 귀신 규정 규칙 균형 그날 그냥 그늘 그러나 그룹 그릇 그림 그제서야 그토록 극복 극히 근거 근교 근래 근로 근무 근본 근원 근육 근처 글씨 글자 금강산 금고 금년 금메달 금액 금연 금요일 금지 긍정적 기간 기관 기념 기능 기독교 기둥 기록 기름 기법 기본 기분 기쁨 기숙사 기술 기억 기업 기온 기운 기원 기적 기준 기침 기혼 기획 긴급 긴장 길이 김밥 김치 김포공항 깍두기 깜빡 깨달음 깨소금 껍질 꼭대기 꽃잎 나들이 나란히 나머지 나물 나침반 나흘 낙엽 난방 날개 날씨 날짜 남녀 남대문 남매 남산 남자 남편 남학생 낭비 낱말 내년 내용 내일 냄비 냄새 냇물 냉동 냉면 냉방 냉장고 넥타이 넷째 노동 노란색 노력 노인 녹음 녹차 녹화 논리 논문 논쟁 놀이 농구 농담 농민 농부 농업 농장 농촌 높이 눈동자 눈물 눈썹 뉴욕 느낌 늑대 능동적 능력 다방 다양성 다음 다이어트 다행 단계 단골 단독 단맛 단순 단어 단위 단점 단체 단추 단편 단풍 달걀 달러 달력 달리 닭고기 담당 담배 담요 담임 답변 답장 당근 당분간 당연히 당장 대규모 대낮 대단히 대답 대도시 대략 대량 대륙 대문 대부분 대신 대응 대장 대전 대접 대중 대책 대출 대충 대통령 대학 대한민국 대합실 대형 덩어리 데이트 도대체 도덕 도둑 도망 도서관 도심 도움 도입 도자기 도저히 도전 도중 도착 독감 독립 독서 독일 독창적 동화책 뒷모습 뒷산 딸아이 마누라 마늘 마당 마라톤 마련 마무리 마사지 마약 마요네즈 마을 마음 마이크 마중 마지막 마찬가지 마찰 마흔 막걸리 막내 막상 만남 만두 만세 만약 만일 만점 만족 만화 많이 말기 말씀 말투 맘대로 망원경 매년 매달 매력 매번 매스컴 매일 매장 맥주 먹이 먼저 먼지 멀리 메일 며느리 며칠 면담 멸치 명단 명령 명예 명의 명절 명칭 명함 모금 모니터 모델 모든 모범 모습 모양 모임 모조리 모집 모퉁이 목걸이 목록 목사 목소리 목숨 목적 목표 몰래 몸매 몸무게 몸살 몸속 몸짓 몸통 몹시 무관심 무궁화 무더위 무덤 무릎 무슨 무엇 무역 무용 무조건 무지개 무척 문구 문득 문법 문서 문제 문학 문화 물가 물건 물결 물고기 물론 물리학 물음 물질 물체 미국 미디어 미사일 미술 미역 미용실 미움 미인 미팅 미혼 민간 민족 민주 믿음 밀가루 밀리미터 밑바닥 바가지 바구니 바나나 바늘 바닥 바닷가 바람 바이러스 바탕 박물관 박사 박수 반대 반드시 반말 반발 반성 반응 반장 반죽 반지 반찬 받침 발가락 발걸음 발견 발달 발레 발목 발바닥 발생 발음 발자국 발전 발톱 발표 밤하늘 밥그릇 밥맛 밥상 밥솥 방금 방면 방문 방바닥 방법 방송 방식 방안 방울 방지 방학 방해 방향 배경 배꼽 배달 배드민턴 백두산 백색 백성 백인 백제 백화점 버릇 버섯 버튼 번개 번역 번지 번호 벌금 벌레 벌써 범위 범인 범죄 법률 법원 법적 법칙 베이징 벨트 변경 변동 변명 변신 변호사 변화 별도 별명 별일 병실 병아리 병원 보관 보너스 보라색 보람 보름 보상 보안 보자기 보장 보전 보존 보통 보편적 보험 복도 복사 복숭아 복습 볶음 본격적 본래 본부 본사 본성 본인 본질 볼펜 봉사 봉지 봉투 부근 부끄러움 부담 부동산 부문 부분 부산 부상 부엌 부인 부작용 부장 부정 부족 부지런히 부친 부탁 부품 부회장 북부 북한 분노 분량 분리 분명 분석 분야 분위기 분필 분홍색 불고기 불과 불교 불꽃 불만 불법 불빛 불안 불이익 불행 브랜드 비극 비난 비닐 비둘기 비디오 비로소 비만 비명 비밀 비바람 비빔밥 비상 비용 비율 비중 비타민 비판 빌딩 빗물 빗방울 빗줄기 빛깔 빨간색 빨래 빨리 사건 사계절 사나이 사냥 사람 사랑 사립 사모님 사물 사방 사상 사생활 사설 사슴 사실 사업 사용 사월 사장 사전 사진 사촌 사춘기 사탕 사투리 사흘 산길 산부인과 산업 산책 살림 살인 살짝 삼계탕 삼국 삼십 삼월 삼촌 상관 상금 상대 상류 상반기 상상 상식 상업 상인 상자 상점 상처 상추 상태 상표 상품 상황 새벽 색깔 색연필 생각 생명 생물 생방송 생산 생선 생신 생일 생활 서랍 서른 서명 서민 서비스 서양 서울 서적 서점 서쪽 서클 석사 석유 선거 선물 선배 선생 선수 선원 선장 선전 선택 선풍기 설거지 설날 설렁탕 설명 설문 설사 설악산 설치 설탕 섭씨 성공 성당 성명 성별 성인 성장 성적 성질 성함 세금 세미나 세상 세월 세종대왕 세탁 센터 센티미터 셋째 소규모 소극적 소금 소나기 소년 소득 소망 소문 소설 소속 소아과 소용 소원 소음 소중히 소지품 소질 소풍 소형 속담 속도 속옷 손가락 손길 손녀 손님 손등 손목 손뼉 손실 손질 손톱 손해 솔직히 솜씨 송아지 송이 송편 쇠고기 쇼핑 수건 수년 수단 수돗물 수동적 수면 수명 수박 수상 수석 수술 수시로 수업 수염 수영 수입 수준 수집 수출 수컷 수필 수학 수험생 수화기 숙녀 숙소 숙제 순간 순서 순수 순식간 순위 숟가락 술병 술집 숫자 스님 스물 스스로 스승 스웨터 스위치 스케이트 스튜디오 스트레스 스포츠 슬쩍 슬픔 습관 습기 승객 승리 승부 승용차 승진 시각 시간 시골 시금치 시나리오 시댁 시리즈 시멘트 시민 시부모 시선 시설 시스템 시아버지 시어머니 시월 시인 시일 시작 시장 시절 시점 시중 시즌 시집 시청 시합 시험 식구 식기 식당 식량 식료품 식물 식빵 식사 식생활 식초 식탁 식품 신고 신규 신념 신문 신발 신비 신사 신세 신용 신제품 신청 신체 신화 실감 실내 실력 실례 실망 실수 실습 실시 실장 실정 실질적 실천 실체 실컷 실태 실패 실험 실현 심리 심부름 심사 심장 심정 심판 쌍둥이 씨름 씨앗 아가씨 아나운서 아드님 아들 아쉬움 아스팔트 아시아 아울러 아저씨 아줌마 아직 아침 아파트 아프리카 아픔 아홉 아흔 악기 악몽 악수 안개 안경 안과 안내 안녕 안동 안방 안부 안주 알루미늄 알코올 암시 암컷 압력 앞날 앞문 애인 애정 액수 앨범 야간 야단 야옹 약간 약국 약속 약수 약점 약품 약혼녀 양념 양력 양말 양배추 양주 양파 어둠 어려움 어른 어젯밤 어쨌든 어쩌다가 어쩐지 언니 언덕 언론 언어 얼굴 얼른 얼음 얼핏 엄마 업무 업종 업체 엉덩이 엉망 엉터리 엊그제 에너지 에어컨 엔진 여건 여고생 여관 여군 여권 여대생 여덟 여동생 여든 여론 여름 여섯 여성 여왕 여인 여전히 여직원 여학생 여행 역사 역시 역할 연결 연구 연극 연기 연락 연설 연세 연속 연습 연애 연예인 연인 연장 연주 연출 연필 연합 연휴 열기 열매 열쇠 열심히 열정 열차 열흘 염려 엽서 영국 영남 영상 영양 영역 영웅 영원히 영하 영향 영혼 영화 옆구리 옆방 옆집 예감 예금 예방 예산 예상 예선 예술 예습 예식장 예약 예전 예절 예정 예컨대 옛날 오늘 오락 오랫동안 오렌지 오로지 오른발 오븐 오십 오염 오월 오전 오직 오징어 오페라 오피스텔 오히려 옥상 옥수수 온갖 온라인 온몸 온종일 온통 올가을 올림픽 올해 옷차림 와이셔츠 와인 완성 완전 왕비 왕자 왜냐하면 왠지 외갓집 외국 외로움 외삼촌 외출 외침 외할머니 왼발 왼손 왼쪽 요금 요일 요즘 요청 용기 용서 용어 우산 우선 우승 우연히 우정 우체국 우편 운동 운명 운반 운전 운행 울산 울음 움직임 웃어른 웃음 워낙 원고 원래 원서 원숭이 원인 원장 원피스 월급 월드컵 월세 월요일 웨이터 위반 위법 위성 위원 위험 위협 윗사람 유난히 유럽 유명 유물 유산 유적 유치원 유학 유행 유형 육군 육상 육십 육체 은행 음력 음료 음반 음성 음식 음악 음주 의견 의논 의문 의복 의식 의심 의외로 의욕 의원 의학 이것 이곳 이념 이놈 이달 이대로 이동 이렇게 이력서 이론적 이름 이민 이발소 이별 이불 이빨 이상 이성 이슬 이야기 이용 이웃 이월 이윽고 이익 이전 이중 이튿날 이틀 이혼 인간 인격 인공 인구 인근 인기 인도 인류 인물 인생 인쇄 인연 인원 인재 인종 인천 인체 인터넷 인하 인형 일곱 일기 일단 일대 일등 일반 일본 일부 일상 일생 일손 일요일 일월 일정 일종 일주일 일찍 일체 일치 일행 일회용 임금 임무 입대 입력 입맛 입사 입술 입시 입원 입장 입학 자가용 자격 자극 자동 자랑 자부심 자식 자신 자연 자원 자율 자전거 자정 자존심 자판 작가 작년 작성 작업 작용 작은딸 작품 잔디 잔뜩 잔치 잘못 잠깐 잠수함 잠시 잠옷 잠자리 잡지 장관 장군 장기간 장래 장례 장르 장마 장면 장모 장미 장비 장사 장소 장식 장애인 장인 장점 장차 장학금 재능 재빨리 재산 재생 재작년 재정 재채기 재판 재학 재활용 저것 저고리 저곳 저녁 저런 저렇게 저번 저울 저절로 저축 적극 적당히 적성 적용 적응 전개 전공 전기 전달 전라도 전망 전문 전반 전부 전세 전시 전용 전자 전쟁 전주 전철 전체 전통 전혀 전후 절대 절망 절반 절약 절차 점검 점수 점심 점원 점점 점차 접근 접시 접촉 젓가락 정거장 정도 정류장 정리 정말 정면 정문 정반대 정보 정부 정비 정상 정성 정오 정원 정장 정지 정치 정확히 제공 제과점 제대로 제목 제발 제법 제삿날 제안 제일 제작 제주도 제출 제품 제한 조각 조건 조금 조깅 조명 조미료 조상 조선 조용히 조절 조정 조직 존댓말 존재 졸업 졸음 종교 종로 종류 종소리 종업원 종종 종합 좌석 죄인 주관적 주름 주말 주머니 주먹 주문 주민 주방 주변 주식 주인 주일 주장 주전자 주택 준비 줄거리 줄기 줄무늬 중간 중계방송 중국 중년 중단 중독 중반 중부 중세 중소기업 중순 중앙 중요 중학교 즉석 즉시 즐거움 증가 증거 증권 증상 증세 지각 지갑 지경 지극히 지금 지급 지능 지름길 지리산 지방 지붕 지식 지역 지우개 지원 지적 지점 지진 지출 직선 직업 직원 직장 진급 진동 진로 진료 진리 진짜 진찰 진출 진통 진행 질문 질병 질서 짐작 집단 집안 집중 짜증 찌꺼기 차남 차라리 차량 차림 차별 차선 차츰 착각 찬물 찬성 참가 참기름 참새 참석 참여 참외 참조 찻잔 창가 창고 창구 창문 창밖 창작 창조 채널 채점 책가방 책방 책상 책임 챔피언 처벌 처음 천국 천둥 천장 천재 천천히 철도 철저히 철학 첫날 첫째 청년 청바지 청소 청춘 체계 체력 체온 체육 체중 체험 초등학생 초반 초밥 초상화 초순 초여름 초원 초저녁 초점 초청 초콜릿 촛불 총각 총리 총장 촬영 최근 최상 최선 최신 최악 최종 추석 추억 추진 추천 추측 축구 축소 축제 축하 출근 출발 출산 출신 출연 출입 출장 출판 충격 충고 충돌 충분히 충청도 취업 취직 취향 치약 친구 친척 칠십 칠월 칠판 침대 침묵 침실 칫솔 칭찬 카메라 카운터 칼국수 캐릭터 캠퍼스 캠페인 커튼 컨디션 컬러 컴퓨터 코끼리 코미디 콘서트 콜라 콤플렉스 콩나물 쾌감 쿠데타 크림 큰길 큰딸 큰소리 큰아들 큰어머니 큰일 큰절 클래식 클럽 킬로 타입 타자기 탁구 탁자 탄생 태권도 태양 태풍 택시 탤런트 터널 터미널 테니스 테스트 테이블 텔레비전 토론 토마토 토요일 통계 통과 통로 통신 통역 통일 통장 통제 통증 통합 통화 퇴근 퇴원 퇴직금 튀김 트럭 특급 특별 특성 특수 특징 특히 튼튼히 티셔츠 파란색 파일 파출소 판결 판단 판매 판사 팔십 팔월 팝송 패션 팩스 팩시밀리 팬티 퍼센트 페인트 편견 편의 편지 편히 평가 평균 평생 평소 평양 평일 평화 포스터 포인트 포장 포함 표면 표정 표준 표현 품목 품질 풍경 풍속 풍습 프랑스 프린터 플라스틱 피곤 피망 피아노 필름 필수 필요 필자 필통 핑계 하느님 하늘 하드웨어 하룻밤 하반기 하숙집 하순 하여튼 하지만 하천 하품 하필 학과 학교 학급 학기 학년 학력 학번 학부모 학비 학생 학술 학습 학용품 학원 학위 학자 학점 한계 한글 한꺼번에 한낮 한눈 한동안 한때 한라산 한마디 한문 한번 한복 한식 한여름 한쪽 할머니 할아버지 할인 함께 함부로 합격 합리적 항공 항구 항상 항의 해결 해군 해답 해당 해물 해석 해설 해수욕장 해안 핵심 핸드백 햄버거 햇볕 햇살 행동 행복 행사 행운 행위 향기 향상 향수 허락 허용 헬기 현관 현금 현대 현상 현실 현장 현재 현지 혈액 협력 형부 형사 형수 형식 형제 형태 형편 혜택 호기심 호남 호랑이 호박 호텔 호흡 혹시 홀로 홈페이지 홍보 홍수 홍차 화면 화분 화살 화요일 화장 화학 확보 확인 확장 확정 환갑 환경 환영 환율 환자 활기 활동 활발히 활용 활짝 회견 회관 회복 회색 회원 회장 회전 횟수 횡단보도 효율적 후반 후춧가루 훈련 훨씬 휴식 휴일 흉내 흐름 흑백 흑인 흔적 흔히 흥미 흥분 희곡 희망 희생 흰색 힘껏)
declare -a portuguese=(abacate abaixo abalar abater abduzir abelha aberto abismo abotoar abranger abreviar abrigar abrupto absinto absoluto absurdo abutre acabado acalmar acampar acanhar acaso aceitar acelerar acenar acervo acessar acetona achatar acidez acima acionado acirrar aclamar aclive acolhida acomodar acoplar acordar acumular acusador adaptar adega adentro adepto adequar aderente adesivo adeus adiante aditivo adjetivo adjunto admirar adorar adquirir adubo adverso advogado aeronave afastar aferir afetivo afinador afivelar aflito afluente afrontar agachar agarrar agasalho agenciar agilizar agiota agitado agora agradar agreste agrupar aguardar agulha ajoelhar ajudar ajustar alameda alarme alastrar alavanca albergue albino alcatra aldeia alecrim alegria alertar alface alfinete algum alheio aliar alicate alienar alinhar aliviar almofada alocar alpiste alterar altitude alucinar alugar aluno alusivo alvo amaciar amador amarelo amassar ambas ambiente ameixa amenizar amido amistoso amizade amolador amontoar amoroso amostra amparar ampliar ampola anagrama analisar anarquia anatomia andaime anel anexo angular animar anjo anomalia anotado ansioso anterior anuidade anunciar anzol apagador apalpar apanhado apego apelido apertada apesar apetite apito aplauso aplicada apoio apontar aposta aprendiz aprovar aquecer arame aranha arara arcada ardente areia arejar arenito aresta argiloso argola arma arquivo arraial arrebate arriscar arroba arrumar arsenal arterial artigo arvoredo asfaltar asilado aspirar assador assinar assoalho assunto astral atacado atadura atalho atarefar atear atender aterro ateu atingir atirador ativo atoleiro atracar atrevido atriz atual atum auditor aumentar aura aurora autismo autoria autuar avaliar avante avaria avental avesso aviador avisar avulso axila azarar azedo azeite azulejo babar babosa bacalhau bacharel bacia bagagem baiano bailar baioneta bairro baixista bajular baleia baliza balsa banal bandeira banho banir banquete barato barbado baronesa barraca barulho baseado bastante batata batedor batida batom batucar baunilha beber beijo beirada beisebol beldade beleza belga beliscar bendito bengala benzer berimbau berlinda berro besouro bexiga bezerro bico bicudo bienal bifocal bifurcar bigorna bilhete bimestre bimotor biologia biombo biosfera bipolar birrento biscoito bisneto bispo bissexto bitola bizarro blindado bloco bloquear boato bobagem bocado bocejo bochecha boicotar bolada boletim bolha bolo bombeiro bonde boneco bonita borbulha borda boreal borracha bovino boxeador branco brasa braveza breu briga brilho brincar broa brochura bronzear broto bruxo bucha budismo bufar bule buraco busca busto buzina cabana cabelo cabide cabo cabrito cacau cacetada cachorro cacique cadastro cadeado cafezal caiaque caipira caixote cajado caju calafrio calcular caldeira calibrar calmante calota camada cambista camisa camomila campanha camuflar canavial cancelar caneta canguru canhoto canivete canoa cansado cantar canudo capacho capela capinar capotar capricho captador capuz caracol carbono cardeal careca carimbar carneiro carpete carreira cartaz carvalho casaco casca casebre castelo casulo catarata cativar caule causador cautelar cavalo caverna cebola cedilha cegonha celebrar celular cenoura censo centeio cercar cerrado certeiro cerveja cetim cevada chacota chaleira chamado chapada charme chatice chave chefe chegada cheiro cheque chicote chifre chinelo chocalho chover chumbo chutar chuva cicatriz ciclone cidade cidreira ciente cigana cimento cinto cinza ciranda circuito cirurgia citar clareza clero clicar clone clube coado coagir cobaia cobertor cobrar cocada coelho coentro coeso cogumelo coibir coifa coiote colar coleira colher colidir colmeia colono coluna comando combinar comentar comitiva comover complexo comum concha condor conectar confuso congelar conhecer conjugar consumir contrato convite cooperar copeiro copiador copo coquetel coragem cordial corneta coronha corporal correio cortejo coruja corvo cosseno costela cotonete couro couve covil cozinha cratera cravo creche credor creme crer crespo criada criminal crioulo crise criticar crosta crua cruzeiro cubano cueca cuidado cujo culatra culminar culpar cultura cumprir cunhado cupido curativo curral cursar curto cuspir custear cutelo damasco datar debater debitar deboche debulhar decalque decimal declive decote decretar dedal dedicado deduzir defesa defumar degelo degrau degustar deitado deixar delator delegado delinear delonga demanda demitir demolido dentista depenado depilar depois depressa depurar deriva derramar desafio desbotar descanso desenho desfiado desgaste desigual deslize desmamar desova despesa destaque desviar detalhar detentor detonar detrito deusa dever devido devotado dezena diagrama dialeto didata difuso digitar dilatado diluente diminuir dinastia dinheiro diocese direto discreta disfarce disparo disquete dissipar distante ditador diurno diverso divisor divulgar dizer dobrador dolorido domador dominado donativo donzela dormente dorsal dosagem dourado doutor drenagem drible drogaria duelar duende dueto duplo duquesa durante duvidoso eclodir ecoar ecologia edificar edital educado efeito efetivar ejetar elaborar eleger eleitor elenco elevador eliminar elogiar embargo embolado embrulho embutido emenda emergir emissor empatia empenho empinado empolgar emprego empurrar emulador encaixe encenado enchente encontro endeusar endossar enfaixar enfeite enfim engajado engenho englobar engomado engraxar enguia enjoar enlatar enquanto enraizar enrolado enrugar ensaio enseada ensino ensopado entanto enteado entidade entortar entrada entulho envergar enviado envolver enxame enxerto enxofre enxuto epiderme equipar ereto erguido errata erva ervilha esbanjar esbelto escama escola escrita escuta esfinge esfolar esfregar esfumado esgrima esmalte espanto espelho espiga esponja espreita espumar esquerda estaca esteira esticar estofado estrela estudo esvaziar etanol etiqueta euforia europeu evacuar evaporar evasivo eventual evidente evoluir exagero exalar examinar exato exausto excesso excitar exclamar executar exemplo exibir exigente exonerar expandir expelir expirar explanar exposto expresso expulsar externo extinto extrato fabricar fabuloso faceta facial fada fadiga faixa falar falta familiar fandango fanfarra fantoche fardado farelo farinha farofa farpa fartura fatia fator favorita faxina fazenda fechado feijoada feirante felino feminino fenda feno fera feriado ferrugem ferver festejar fetal feudal fiapo fibrose ficar ficheiro figurado fileira filho filme filtrar firmeza fisgada fissura fita fivela fixador fixo flacidez flamingo flanela flechada flora flutuar fluxo focal focinho fofocar fogo foguete foice folgado folheto forjar formiga forno forte fosco fossa fragata fralda frango frasco fraterno freira frente fretar frieza friso fritura fronha frustrar fruteira fugir fulano fuligem fundar fungo funil furador furioso futebol gabarito gabinete gado gaiato gaiola gaivota galega galho galinha galocha ganhar garagem garfo gargalo garimpo garoupa garrafa gasoduto gasto gata gatilho gaveta gazela gelado geleia gelo gemada gemer gemido generoso gengiva genial genoma genro geologia gerador germinar gesso gestor ginasta gincana gingado girafa girino glacial glicose global glorioso goela goiaba golfe golpear gordura gorjeta gorro gostoso goteira governar gracejo gradual grafite gralha grampo granada gratuito graveto graxa grego grelhar greve grilo grisalho gritaria grosso grotesco grudado grunhido gruta guache guarani guaxinim guerrear guiar guincho guisado gula guloso guru habitar harmonia haste haver hectare herdar heresia hesitar hiato hibernar hidratar hiena hino hipismo hipnose hipoteca hoje holofote homem honesto honrado hormonal hospedar humorado iate ideia idoso ignorado igreja iguana ileso ilha iludido iluminar ilustrar imagem imediato imenso imersivo iminente imitador imortal impacto impedir implante impor imprensa impune imunizar inalador inapto inativo incenso inchar incidir incluir incolor indeciso indireto indutor ineficaz inerente infantil infestar infinito inflamar informal infrator ingerir inibido inicial inimigo injetar inocente inodoro inovador inox inquieto inscrito inseto insistir inspetor instalar insulto intacto integral intimar intocado intriga invasor inverno invicto invocar iogurte iraniano ironizar irreal irritado isca isento isolado isqueiro italiano janeiro jangada janta jararaca jardim jarro jasmim jato javali jazida jejum joaninha joelhada jogador joia jornal jorrar jovem juba judeu judoca juiz julgador julho jurado jurista juro justa labareda laboral lacre lactante ladrilho lagarta lagoa laje lamber lamentar laminar lampejo lanche lapidar lapso laranja lareira largura lasanha lastro lateral latido lavanda lavoura lavrador laxante lazer lealdade lebre legado legendar legista leigo leiloar leitura lembrete leme lenhador lentilha leoa lesma leste letivo letreiro levar leveza levitar liberal libido liderar ligar ligeiro limitar limoeiro limpador linda linear linhagem liquidez listagem lisura litoral livro lixa lixeira locador locutor lojista lombo lona longe lontra lorde lotado loteria loucura lousa louvar luar lucidez lucro luneta lustre lutador luva macaco macete machado macio madeira madrinha magnata magreza maior mais malandro malha malote maluco mamilo mamoeiro mamute manada mancha mandato manequim manhoso manivela manobrar mansa manter manusear mapeado maquinar marcador maresia marfim margem marinho marmita maroto marquise marreco martelo marujo mascote masmorra massagem mastigar matagal materno matinal matutar maxilar medalha medida medusa megafone meiga melancia melhor membro memorial menino menos mensagem mental merecer mergulho mesada mesclar mesmo mesquita mestre metade meteoro metragem mexer mexicano micro migalha migrar milagre milenar milhar mimado minerar minhoca ministro minoria miolo mirante mirtilo misturar mocidade moderno modular moeda moer moinho moita moldura moleza molho molinete molusco montanha moqueca morango morcego mordomo morena mosaico mosquete mostarda motel motim moto motriz muda muito mulata mulher multar mundial munido muralha murcho muscular museu musical nacional nadador naja namoro narina narrado nascer nativa natureza navalha navegar navio neblina nebuloso negativa negociar negrito nervoso neta neural nevasca nevoeiro ninar ninho nitidez nivelar nobreza noite noiva nomear nominal nordeste nortear notar noticiar noturno novelo novilho novo nublado nudez numeral nupcial nutrir nuvem obcecado obedecer objetivo obrigado obscuro obstetra obter obturar ocidente ocioso ocorrer oculista ocupado ofegante ofensiva oferenda oficina ofuscado ogiva olaria oleoso olhar oliveira ombro omelete omisso omitir ondulado oneroso ontem opcional operador oponente oportuno oposto orar orbitar ordem ordinal orfanato orgasmo orgulho oriental origem oriundo orla ortodoxo orvalho oscilar ossada osso ostentar otimismo ousadia outono outubro ouvido ovelha ovular oxidar oxigenar pacato paciente pacote pactuar padaria padrinho pagar pagode painel pairar paisagem palavra palestra palheta palito palmada palpitar pancada panela panfleto panqueca pantanal papagaio papelada papiro parafina parcial pardal parede partida pasmo passado pastel patamar patente patinar patrono paulada pausar peculiar pedalar pedestre pediatra pedra pegada peitoral peixe pele pelicano penca pendurar peneira penhasco pensador pente perceber perfeito pergunta perito permitir perna perplexo persiana pertence peruca pescado pesquisa pessoa petiscar piada picado piedade pigmento pilastra pilhado pilotar pimenta pincel pinguim pinha pinote pintar pioneiro pipoca piquete piranha pires pirueta piscar pistola pitanga pivete planta plaqueta platina plebeu plumagem pluvial pneu poda poeira poetisa polegada policiar poluente polvilho pomar pomba ponderar pontaria populoso porta possuir postal pote poupar pouso povoar praia prancha prato praxe prece predador prefeito premiar prensar preparar presilha pretexto prevenir prezar primata princesa prisma privado processo produto profeta proibido projeto prometer propagar prosa protetor provador publicar pudim pular pulmonar pulseira punhal punir pupilo pureza puxador quadra quantia quarto quase quebrar queda queijo quente querido quimono quina quiosque rabanada rabisco rachar racionar radial raiar rainha raio raiva rajada ralado ramal ranger ranhura rapadura rapel rapidez raposa raquete raridade rasante rascunho rasgar raspador rasteira rasurar ratazana ratoeira realeza reanimar reaver rebaixar rebelde rebolar recado recente recheio recibo recordar recrutar recuar rede redimir redonda reduzida reenvio refinar refletir refogar refresco refugiar regalia regime regra reinado reitor rejeitar relativo remador remendo remorso renovado reparo repelir repleto repolho represa repudiar requerer resenha resfriar resgatar residir resolver respeito ressaca restante resumir retalho reter retirar retomada retratar revelar revisor revolta riacho rica rigidez rigoroso rimar ringue risada risco risonho robalo rochedo rodada rodeio rodovia roedor roleta romano roncar rosado roseira rosto rota roteiro rotina rotular rouco roupa roxo rubro rugido rugoso ruivo rumo rupestre russo sabor saciar sacola sacudir sadio safira saga sagrada saibro salada saleiro salgado saliva salpicar salsicha saltar salvador sambar samurai sanar sanfona sangue sanidade sapato sarda sargento sarjeta saturar saudade saxofone sazonal secar secular seda sedento sediado sedoso sedutor segmento segredo segundo seiva seleto selvagem semanal semente senador senhor sensual sentado separado sereia seringa serra servo setembro setor sigilo silhueta silicone simetria simpatia simular sinal sincero singular sinopse sintonia sirene siri situado soberano sobra socorro sogro soja solda soletrar solteiro sombrio sonata sondar sonegar sonhador sono soprano soquete sorrir sorteio sossego sotaque soterrar sovado sozinho suavizar subida submerso subsolo subtrair sucata sucesso suco sudeste sufixo sugador sugerir sujeito sulfato sumir suor superior suplicar suposto suprimir surdina surfista surpresa surreal surtir suspiro sustento tabela tablete tabuada tacho tagarela talher talo talvez tamanho tamborim tampa tangente tanto tapar tapioca tardio tarefa tarja tarraxa tatuagem taurino taxativo taxista teatral tecer tecido teclado tedioso teia teimar telefone telhado tempero tenente tensor tentar termal terno terreno tese tesoura testado teto textura texugo tiara tigela tijolo timbrar timidez tingido tinteiro tiragem titular toalha tocha tolerar tolice tomada tomilho tonel tontura topete tora torcido torneio torque torrada torto tostar touca toupeira toxina trabalho tracejar tradutor trafegar trajeto trama trancar trapo traseiro tratador travar treino tremer trepidar trevo triagem tribo triciclo tridente trilogia trindade triplo triturar triunfal trocar trombeta trova trunfo truque tubular tucano tudo tulipa tupi turbo turma turquesa tutelar tutorial uivar umbigo unha unidade uniforme urologia urso urtiga urubu usado usina usufruir vacina vadiar vagaroso vaidoso vala valente validade valores vantagem vaqueiro varanda vareta varrer vascular vasilha vassoura vazar vazio veado vedar vegetar veicular veleiro velhice veludo vencedor vendaval venerar ventre verbal verdade vereador vergonha vermelho verniz versar vertente vespa vestido vetorial viaduto viagem viajar viatura vibrador videira vidraria viela viga vigente vigiar vigorar vilarejo vinco vinheta vinil violeta virada virtude visitar visto vitral viveiro vizinho voador voar vogal volante voleibol voltagem volumoso vontade vulto vuvuzela xadrez xarope xeque xeretar xerife xingar zangado zarpar zebu zelador zombar zoologia zumbido)
declare -a spanish=(ábaco abdomen abeja abierto abogado abono aborto abrazo abrir abuelo abuso acabar academia acceso acción aceite acelga acento aceptar ácido aclarar acné acoger acoso activo acto actriz actuar acudir acuerdo acusar adicto admitir adoptar adorno aduana adulto aéreo afectar afición afinar afirmar ágil agitar agonía agosto agotar agregar agrio agua agudo águila aguja ahogo ahorro aire aislar ajedrez ajeno ajuste alacrán alambre alarma alba álbum alcalde aldea alegre alejar alerta aleta alfiler alga algodón aliado aliento alivio alma almeja almíbar altar alteza altivo alto altura alumno alzar amable amante amapola amargo amasar ámbar ámbito ameno amigo amistad amor amparo amplio ancho anciano ancla andar andén anemia ángulo anillo ánimo anís anotar antena antiguo antojo anual anular anuncio añadir añejo año apagar aparato apetito apio aplicar apodo aporte apoyo aprender aprobar apuesta apuro arado araña arar árbitro árbol arbusto archivo arco arder ardilla arduo área árido aries armonía arnés aroma arpa arpón arreglo arroz arruga arte artista asa asado asalto ascenso asegurar aseo asesor asiento asilo asistir asno asombro áspero astilla astro astuto asumir asunto atajo ataque atar atento ateo ático atleta átomo atraer atroz atún audaz audio auge aula aumento ausente autor aval avance avaro ave avellana avena avestruz avión aviso ayer ayuda ayuno azafrán azar azote azúcar azufre azul baba babor bache bahía baile bajar balanza balcón balde bambú banco banda baño barba barco barniz barro báscula bastón basura batalla batería batir batuta baúl bazar bebé bebida bello besar beso bestia bicho bien bingo blanco bloque blusa boa bobina bobo boca bocina boda bodega boina bola bolero bolsa bomba bondad bonito bono bonsái borde borrar bosque bote botín bóveda bozal bravo brazo brecha breve brillo brinco brisa broca broma bronce brote bruja brusco bruto buceo bucle bueno buey bufanda bufón búho buitre bulto burbuja burla burro buscar butaca buzón caballo cabeza cabina cabra cacao cadáver cadena caer café caída caimán caja cajón cal calamar calcio caldo calidad calle calma calor calvo cama cambio camello camino campo cáncer candil canela canguro canica canto caña cañón caoba caos capaz capitán capote captar capucha cara carbón cárcel careta carga cariño carne carpeta carro carta casa casco casero caspa castor catorce catre caudal causa cazo cebolla ceder cedro celda célebre celoso célula cemento ceniza centro cerca cerdo cereza cero cerrar certeza césped cetro chacal chaleco champú chancla chapa charla chico chiste chivo choque choza chuleta chupar ciclón ciego cielo cien cierto cifra cigarro cima cinco cine cinta ciprés circo ciruela cisne cita ciudad clamor clan claro clase clave cliente clima clínica cobre cocción cochino cocina coco código codo cofre coger cohete cojín cojo cola colcha colegio colgar colina collar colmo columna combate comer comida cómodo compra conde conejo conga conocer consejo contar copa copia corazón corbata corcho cordón corona correr coser cosmos costa cráneo cráter crear crecer creído crema cría crimen cripta crisis cromo crónica croqueta crudo cruz cuadro cuarto cuatro cubo cubrir cuchara cuello cuento cuerda cuesta cueva cuidar culebra culpa culto cumbre cumplir cuna cuneta cuota cupón cúpula curar curioso curso curva cutis dama danza dar dardo dátil deber débil década decir dedo defensa definir dejar delfín delgado delito demora denso dental deporte derecho derrota desayuno deseo desfile desnudo destino desvío detalle detener deuda día diablo diadema diamante diana diario dibujo dictar diente dieta diez difícil digno dilema diluir dinero directo dirigir disco diseño disfraz diva divino doble doce dolor domingo don donar dorado dormir dorso dos dosis dragón droga ducha duda duelo dueño dulce dúo duque durar dureza duro ébano ebrio echar eco ecuador edad edición edificio editor educar efecto eficaz eje ejemplo elefante elegir elemento elevar elipse élite elixir elogio eludir embudo emitir emoción empate empeño empleo empresa enano encargo enchufe encía enemigo enero enfado enfermo engaño enigma enlace enorme enredo ensayo enseñar entero entrar envase envío época equipo erizo escala escena escolar escribir escudo esencia esfera esfuerzo espada espejo espía esposa espuma esquí estar este estilo estufa etapa eterno ética etnia evadir evaluar evento evitar exacto examen exceso excusa exento exigir exilio existir éxito experto explicar exponer extremo fábrica fábula fachada fácil factor faena faja falda fallo falso faltar fama familia famoso faraón farmacia farol farsa fase fatiga fauna favor fax febrero fecha feliz feo feria feroz fértil fervor festín fiable fianza fiar fibra ficción ficha fideo fiebre fiel fiera fiesta figura fijar fijo fila filete filial filtro fin finca fingir finito firma flaco flauta flecha flor flota fluir flujo flúor fobia foca fogata fogón folio folleto fondo forma forro fortuna forzar fosa foto fracaso frágil franja frase fraude freír freno fresa frío frito fruta fuego fuente fuerza fuga fumar función funda furgón furia fusil fútbol futuro gacela gafas gaita gajo gala galería gallo gamba ganar gancho ganga ganso garaje garza gasolina gastar gato gavilán gemelo gemir gen género genio gente geranio gerente germen gesto gigante gimnasio girar giro glaciar globo gloria gol golfo goloso golpe goma gordo gorila gorra gota goteo gozar grada gráfico grano grasa gratis grave grieta grillo gripe gris grito grosor grúa grueso grumo grupo guante guapo guardia guerra guía guiño guion guiso guitarra gusano gustar haber hábil hablar hacer hacha hada hallar hamaca harina haz hazaña hebilla hebra hecho helado helio hembra herir hermano héroe hervir hielo hierro hígado higiene hijo himno historia hocico hogar hoguera hoja hombre hongo honor honra hora hormiga horno hostil hoyo hueco huelga huerta hueso huevo huida huir humano húmedo humilde humo hundir huracán hurto icono ideal idioma ídolo iglesia iglú igual ilegal ilusión imagen imán imitar impar imperio imponer impulso incapaz índice inerte infiel informe ingenio inicio inmenso inmune innato insecto instante interés íntimo intuir inútil invierno ira iris ironía isla islote jabalí jabón jamón jarabe jardín jarra jaula jazmín jefe jeringa jinete jornada joroba joven joya juerga jueves juez jugador jugo juguete juicio junco jungla junio juntar júpiter jurar justo juvenil juzgar kilo koala labio lacio lacra lado ladrón lagarto lágrima laguna laico lamer lámina lámpara lana lancha langosta lanza lápiz largo larva lástima lata látex latir laurel lavar lazo leal lección leche lector leer legión legumbre lejano lengua lento leña león leopardo lesión letal letra leve leyenda libertad libro licor líder lidiar lienzo liga ligero lima límite limón limpio lince lindo línea lingote lino linterna líquido liso lista litera litio litro llaga llama llanto llave llegar llenar llevar llorar llover lluvia lobo loción loco locura lógica logro lombriz lomo lonja lote lucha lucir lugar lujo luna lunes lupa lustro luto luz maceta macho madera madre maduro maestro mafia magia mago maíz maldad maleta malla malo mamá mambo mamut manco mando manejar manga maniquí manjar mano manso manta mañana mapa máquina mar marco marea marfil margen marido mármol marrón martes marzo masa máscara masivo matar materia matiz matriz máximo mayor mazorca mecha medalla medio médula mejilla mejor melena melón memoria menor mensaje mente menú mercado merengue mérito mes mesón meta meter método metro mezcla miedo miel miembro miga mil milagro militar millón mimo mina minero mínimo minuto miope mirar misa miseria misil mismo mitad mito mochila moción moda modelo moho mojar molde moler molino momento momia monarca moneda monja monto moño morada morder moreno morir morro morsa mortal mosca mostrar motivo mover móvil mozo mucho mudar mueble muela muerte muestra mugre mujer mula muleta multa mundo muñeca mural muro músculo museo musgo música muslo nácar nación nadar naipe naranja nariz narrar nasal natal nativo natural náusea naval nave navidad necio néctar negar negocio negro neón nervio neto neutro nevar nevera nicho nido niebla nieto niñez niño nítido nivel nobleza noche nómina noria norma norte nota noticia novato novela novio nube nuca núcleo nudillo nudo nuera nueve nuez nulo número nutria oasis obeso obispo objeto obra obrero observar obtener obvio oca ocaso océano ochenta ocho ocio ocre octavo octubre oculto ocupar ocurrir odiar odio odisea oeste ofensa oferta oficio ofrecer ogro oído oír ojo ola oleada olfato olivo olla olmo olor olvido ombligo onda onza opaco opción ópera opinar oponer optar óptica opuesto oración orador oral órbita orca orden oreja órgano orgía orgullo oriente origen orilla oro orquesta oruga osadía oscuro osezno oso ostra otoño otro oveja óvulo óxido oxígeno oyente ozono pacto padre paella página pago país pájaro palabra palco paleta pálido palma paloma palpar pan panal pánico pantera pañuelo papá papel papilla paquete parar parcela pared parir paro párpado parque párrafo parte pasar paseo pasión paso pasta pata patio patria pausa pauta pavo payaso peatón pecado pecera pecho pedal pedir pegar peine pelar peldaño pelea peligro pellejo pelo peluca pena pensar peñón peón peor pepino pequeño pera percha perder pereza perfil perico perla permiso perro persona pesa pesca pésimo pestaña pétalo petróleo pez pezuña picar pichón pie piedra pierna pieza pijama pilar piloto pimienta pino pintor pinza piña piojo pipa pirata pisar piscina piso pista pitón pizca placa plan plata playa plaza pleito pleno plomo pluma plural pobre poco poder podio poema poesía poeta polen policía pollo polvo pomada pomelo pomo pompa poner porción portal posada poseer posible poste potencia potro pozo prado precoz pregunta premio prensa preso previo primo príncipe prisión privar proa probar proceso producto proeza profesor programa prole promesa pronto propio próximo prueba público puchero pudor pueblo puerta puesto pulga pulir pulmón pulpo pulso puma punto puñal puño pupa pupila puré quedar queja quemar querer queso quieto química quince quitar rábano rabia rabo ración radical raíz rama rampa rancho rango rapaz rápido rapto rasgo raspa rato rayo raza razón reacción realidad rebaño rebote recaer receta rechazo recoger recreo recto recurso red redondo reducir reflejo reforma refrán refugio regalo regir regla regreso rehén reino reír reja relato relevo relieve relleno reloj remar remedio remo rencor rendir renta reparto repetir reposo reptil res rescate resina respeto resto resumen retiro retorno retrato reunir revés revista rey rezar rico riego rienda riesgo rifa rígido rigor rincón riñón río riqueza risa ritmo rito rizo roble roce rociar rodar rodeo rodilla roer rojizo rojo romero romper ron ronco ronda ropa ropero rosa rosca rostro rotar rubí rubor rudo rueda rugir ruido ruina ruleta rulo rumbo rumor ruptura ruta rutina sábado saber sabio sable sacar sagaz sagrado sala saldo salero salir salmón salón salsa salto salud salvar samba sanción sandía sanear sangre sanidad sano santo sapo saque sardina sartén sastre satán sauna saxofón sección seco secreto secta sed seguir seis sello selva semana semilla senda sensor señal señor separar sepia sequía ser serie sermón servir sesenta sesión seta setenta severo sexo sexto sidra siesta siete siglo signo sílaba silbar silencio silla símbolo simio sirena sistema sitio situar sobre socio sodio sol solapa soldado soledad sólido soltar solución sombra sondeo sonido sonoro sonrisa sopa soplar soporte sordo sorpresa sorteo sostén sótano suave subir suceso sudor suegra suelo sueño suerte sufrir sujeto sultán sumar superar suplir suponer supremo sur surco sureño surgir susto sutil tabaco tabique tabla tabú taco tacto tajo talar talco talento talla talón tamaño tambor tango tanque tapa tapete tapia tapón taquilla tarde tarea tarifa tarjeta tarot tarro tarta tatuaje tauro taza tazón teatro techo tecla técnica tejado tejer tejido tela teléfono tema temor templo tenaz tender tener tenis tenso teoría terapia terco término ternura terror tesis tesoro testigo tetera texto tez tibio tiburón tiempo tienda tierra tieso tigre tijera tilde timbre tímido timo tinta tío típico tipo tira tirón titán títere título tiza toalla tobillo tocar tocino todo toga toldo tomar tono tonto topar tope toque tórax torero tormenta torneo toro torpedo torre torso tortuga tos tosco toser tóxico trabajo tractor traer tráfico trago traje tramo trance trato trauma trazar trébol tregua treinta tren trepar tres tribu trigo tripa triste triunfo trofeo trompa tronco tropa trote trozo truco trueno trufa tubería tubo tuerto tumba tumor túnel túnica turbina turismo turno tutor ubicar úlcera umbral unidad unir universo uno untar uña urbano urbe urgente urna usar usuario útil utopía uva vaca vacío vacuna vagar vago vaina vajilla vale válido valle valor válvula vampiro vara variar varón vaso vecino vector vehículo veinte vejez vela velero veloz vena vencer venda veneno vengar venir venta venus ver verano verbo verde vereda verja verso verter vía viaje vibrar vicio víctima vida vídeo vidrio viejo viernes vigor vil villa vinagre vino viñedo violín viral virgo virtud visor víspera vista vitamina viudo vivaz vivero vivir vivo volcán volumen volver voraz votar voto voz vuelo vulgar yacer yate yegua yema yerno yeso yodo yoga yogur zafiro zanja zapato zarza zona zorro zumo zurdo)
declare -a chinese_simplified=(的 一 是 在 不 了 有 和 人 这 中 大 为 上 个 国 我 以 要 他 时 来 用 们 生 到 作 地 于 出 就 分 对 成 会 可 主 发 年 动 同 工 也 能 下 过 子 说 产 种 面 而 方 后 多 定 行 学 法 所 民 得 经 十 三 之 进 着 等 部 度 家 电 力 里 如 水 化 高 自 二 理 起 小 物 现 实 加 量 都 两 体 制 机 当 使 点 从 业 本 去 把 性 好 应 开 它 合 还 因 由 其 些 然 前 外 天 政 四 日 那 社 义 事 平 形 相 全 表 间 样 与 关 各 重 新 线 内 数 正 心 反 你 明 看 原 又 么 利 比 或 但 质 气 第 向 道 命 此 变 条 只 没 结 解 问 意 建 月 公 无 系 军 很 情 者 最 立 代 想 已 通 并 提 直 题 党 程 展 五 果 料 象 员 革 位 入 常 文 总 次 品 式 活 设 及 管 特 件 长 求 老 头 基 资 边 流 路 级 少 图 山 统 接 知 较 将 组 见 计 别 她 手 角 期 根 论 运 农 指 几 九 区 强 放 决 西 被 干 做 必 战 先 回 则 任 取 据 处 队 南 给 色 光 门 即 保 治 北 造 百 规 热 领 七 海 口 东 导 器 压 志 世 金 增 争 济 阶 油 思 术 极 交 受 联 什 认 六 共 权 收 证 改 清 美 再 采 转 更 单 风 切 打 白 教 速 花 带 安 场 身 车 例 真 务 具 万 每 目 至 达 走 积 示 议 声 报 斗 完 类 八 离 华 名 确 才 科 张 信 马 节 话 米 整 空 元 况 今 集 温 传 土 许 步 群 广 石 记 需 段 研 界 拉 林 律 叫 且 究 观 越 织 装 影 算 低 持 音 众 书 布 复 容 儿 须 际 商 非 验 连 断 深 难 近 矿 千 周 委 素 技 备 半 办 青 省 列 习 响 约 支 般 史 感 劳 便 团 往 酸 历 市 克 何 除 消 构 府 称 太 准 精 值 号 率 族 维 划 选 标 写 存 候 毛 亲 快 效 斯 院 查 江 型 眼 王 按 格 养 易 置 派 层 片 始 却 专 状 育 厂 京 识 适 属 圆 包 火 住 调 满 县 局 照 参 红 细 引 听 该 铁 价 严 首 底 液 官 德 随 病 苏 失 尔 死 讲 配 女 黄 推 显 谈 罪 神 艺 呢 席 含 企 望 密 批 营 项 防 举 球 英 氧 势 告 李 台 落 木 帮 轮 破 亚 师 围 注 远 字 材 排 供 河 态 封 另 施 减 树 溶 怎 止 案 言 士 均 武 固 叶 鱼 波 视 仅 费 紧 爱 左 章 早 朝 害 续 轻 服 试 食 充 兵 源 判 护 司 足 某 练 差 致 板 田 降 黑 犯 负 击 范 继 兴 似 余 坚 曲 输 修 故 城 夫 够 送 笔 船 占 右 财 吃 富 春 职 觉 汉 画 功 巴 跟 虽 杂 飞 检 吸 助 升 阳 互 初 创 抗 考 投 坏 策 古 径 换 未 跑 留 钢 曾 端 责 站 简 述 钱 副 尽 帝 射 草 冲 承 独 令 限 阿 宣 环 双 请 超 微 让 控 州 良 轴 找 否 纪 益 依 优 顶 础 载 倒 房 突 坐 粉 敌 略 客 袁 冷 胜 绝 析 块 剂 测 丝 协 诉 念 陈 仍 罗 盐 友 洋 错 苦 夜 刑 移 频 逐 靠 混 母 短 皮 终 聚 汽 村 云 哪 既 距 卫 停 烈 央 察 烧 迅 境 若 印 洲 刻 括 激 孔 搞 甚 室 待 核 校 散 侵 吧 甲 游 久 菜 味 旧 模 湖 货 损 预 阻 毫 普 稳 乙 妈 植 息 扩 银 语 挥 酒 守 拿 序 纸 医 缺 雨 吗 针 刘 啊 急 唱 误 训 愿 审 附 获 茶 鲜 粮 斤 孩 脱 硫 肥 善 龙 演 父 渐 血 欢 械 掌 歌 沙 刚 攻 谓 盾 讨 晚 粒 乱 燃 矛 乎 杀 药 宁 鲁 贵 钟 煤 读 班 伯 香 介 迫 句 丰 培 握 兰 担 弦 蛋 沉 假 穿 执 答 乐 谁 顺 烟 缩 征 脸 喜 松 脚 困 异 免 背 星 福 买 染 井 概 慢 怕 磁 倍 祖 皇 促 静 补 评 翻 肉 践 尼 衣 宽 扬 棉 希 伤 操 垂 秋 宜 氢 套 督 振 架 亮 末 宪 庆 编 牛 触 映 雷 销 诗 座 居 抓 裂 胞 呼 娘 景 威 绿 晶 厚 盟 衡 鸡 孙 延 危 胶 屋 乡 临 陆 顾 掉 呀 灯 岁 措 束 耐 剧 玉 赵 跳 哥 季 课 凯 胡 额 款 绍 卷 齐 伟 蒸 殖 永 宗 苗 川 炉 岩 弱 零 杨 奏 沿 露 杆 探 滑 镇 饭 浓 航 怀 赶 库 夺 伊 灵 税 途 灭 赛 归 召 鼓 播 盘 裁 险 康 唯 录 菌 纯 借 糖 盖 横 符 私 努 堂 域 枪 润 幅 哈 竟 熟 虫 泽 脑 壤 碳 欧 遍 侧 寨 敢 彻 虑 斜 薄 庭 纳 弹 饲 伸 折 麦 湿 暗 荷 瓦 塞 床 筑 恶 户 访 塔 奇 透 梁 刀 旋 迹 卡 氯 遇 份 毒 泥 退 洗 摆 灰 彩 卖 耗 夏 择 忙 铜 献 硬 予 繁 圈 雪 函 亦 抽 篇 阵 阴 丁 尺 追 堆 雄 迎 泛 爸 楼 避 谋 吨 野 猪 旗 累 偏 典 馆 索 秦 脂 潮 爷 豆 忽 托 惊 塑 遗 愈 朱 替 纤 粗 倾 尚 痛 楚 谢 奋 购 磨 君 池 旁 碎 骨 监 捕 弟 暴 割 贯 殊 释 词 亡 壁 顿 宝 午 尘 闻 揭 炮 残 冬 桥 妇 警 综 招 吴 付 浮 遭 徐 您 摇 谷 赞 箱 隔 订 男 吹 园 纷 唐 败 宋 玻 巨 耕 坦 荣 闭 湾 键 凡 驻 锅 救 恩 剥 凝 碱 齿 截 炼 麻 纺 禁 废 盛 版 缓 净 睛 昌 婚 涉 筒 嘴 插 岸 朗 庄 街 藏 姑 贸 腐 奴 啦 惯 乘 伙 恢 匀 纱 扎 辩 耳 彪 臣 亿 璃 抵 脉 秀 萨 俄 网 舞 店 喷 纵 寸 汗 挂 洪 贺 闪 柬 爆 烯 津 稻 墙 软 勇 像 滚 厘 蒙 芳 肯 坡 柱 荡 腿 仪 旅 尾 轧 冰 贡 登 黎 削 钻 勒 逃 障 氨 郭 峰 币 港 伏 轨 亩 毕 擦 莫 刺 浪 秘 援 株 健 售 股 岛 甘 泡 睡 童 铸 汤 阀 休 汇 舍 牧 绕 炸 哲 磷 绩 朋 淡 尖 启 陷 柴 呈 徒 颜 泪 稍 忘 泵 蓝 拖 洞 授 镜 辛 壮 锋 贫 虚 弯 摩 泰 幼 廷 尊 窗 纲 弄 隶 疑 氏 宫 姐 震 瑞 怪 尤 琴 循 描 膜 违 夹 腰 缘 珠 穷 森 枝 竹 沟 催 绳 忆 邦 剩 幸 浆 栏 拥 牙 贮 礼 滤 钠 纹 罢 拍 咱 喊 袖 埃 勤 罚 焦 潜 伍 墨 欲 缝 姓 刊 饱 仿 奖 铝 鬼 丽 跨 默 挖 链 扫 喝 袋 炭 污 幕 诸 弧 励 梅 奶 洁 灾 舟 鉴 苯 讼 抱 毁 懂 寒 智 埔 寄 届 跃 渡 挑 丹 艰 贝 碰 拔 爹 戴 码 梦 芽 熔 赤 渔 哭 敬 颗 奔 铅 仲 虎 稀 妹 乏 珍 申 桌 遵 允 隆 螺 仓 魏 锐 晓 氮 兼 隐 碍 赫 拨 忠 肃 缸 牵 抢 博 巧 壳 兄 杜 讯 诚 碧 祥 柯 页 巡 矩 悲 灌 龄 伦 票 寻 桂 铺 圣 恐 恰 郑 趣 抬 荒 腾 贴 柔 滴 猛 阔 辆 妻 填 撤 储 签 闹 扰 紫 砂 递 戏 吊 陶 伐 喂 疗 瓶 婆 抚 臂 摸 忍 虾 蜡 邻 胸 巩 挤 偶 弃 槽 劲 乳 邓 吉 仁 烂 砖 租 乌 舰 伴 瓜 浅 丙 暂 燥 橡 柳 迷 暖 牌 秧 胆 详 簧 踏 瓷 谱 呆 宾 糊 洛 辉 愤 竞 隙 怒 粘 乃 绪 肩 籍 敏 涂 熙 皆 侦 悬 掘 享 纠 醒 狂 锁 淀 恨 牲 霸 爬 赏 逆 玩 陵 祝 秒 浙 貌 役 彼 悉 鸭 趋 凤 晨 畜 辈 秩 卵 署 梯 炎 滩 棋 驱 筛 峡 冒 啥 寿 译 浸 泉 帽 迟 硅 疆 贷 漏 稿 冠 嫩 胁 芯 牢 叛 蚀 奥 鸣 岭 羊 凭 串 塘 绘 酵 融 盆 锡 庙 筹 冻 辅 摄 袭 筋 拒 僚 旱 钾 鸟 漆 沈 眉 疏 添 棒 穗 硝 韩 逼 扭 侨 凉 挺 碗 栽 炒 杯 患 馏 劝 豪 辽 勃 鸿 旦 吏 拜 狗 埋 辊 掩 饮 搬 骂 辞 勾 扣 估 蒋 绒 雾 丈 朵 姆 拟 宇 辑 陕 雕 偿 蓄 崇 剪 倡 厅 咬 驶 薯 刷 斥 番 赋 奉 佛 浇 漫 曼 扇 钙 桃 扶 仔 返 俗 亏 腔 鞋 棱 覆 框 悄 叔 撞 骗 勘 旺 沸 孤 吐 孟 渠 屈 疾 妙 惜 仰 狠 胀 谐 抛 霉 桑 岗 嘛 衰 盗 渗 脏 赖 涌 甜 曹 阅 肌 哩 厉 烃 纬 毅 昨 伪 症 煮 叹 钉 搭 茎 笼 酷 偷 弓 锥 恒 杰 坑 鼻 翼 纶 叙 狱 逮 罐 络 棚 抑 膨 蔬 寺 骤 穆 冶 枯 册 尸 凸 绅 坯 牺 焰 轰 欣 晋 瘦 御 锭 锦 丧 旬 锻 垄 搜 扑 邀 亭 酯 迈 舒 脆 酶 闲 忧 酚 顽 羽 涨 卸 仗 陪 辟 惩 杭 姚 肚 捉 飘 漂 昆 欺 吾 郎 烷 汁 呵 饰 萧 雅 邮 迁 燕 撒 姻 赴 宴 烦 债 帐 斑 铃 旨 醇 董 饼 雏 姿 拌 傅 腹 妥 揉 贤 拆 歪 葡 胺 丢 浩 徽 昂 垫 挡 览 贪 慰 缴 汪 慌 冯 诺 姜 谊 凶 劣 诬 耀 昏 躺 盈 骑 乔 溪 丛 卢 抹 闷 咨 刮 驾 缆 悟 摘 铒 掷 颇 幻 柄 惠 惨 佳 仇 腊 窝 涤 剑 瞧 堡 泼 葱 罩 霍 捞 胎 苍 滨 俩 捅 湘 砍 霞 邵 萄 疯 淮 遂 熊 粪 烘 宿 档 戈 驳 嫂 裕 徙 箭 捐 肠 撑 晒 辨 殿 莲 摊 搅 酱 屏 疫 哀 蔡 堵 沫 皱 畅 叠 阁 莱 敲 辖 钩 痕 坝 巷 饿 祸 丘 玄 溜 曰 逻 彭 尝 卿 妨 艇 吞 韦 怨 矮 歇)
declare -a chinese_traditional=(的 一 是 在 不 了 有 和 人 這 中 大 為 上 個 國 我 以 要 他 時 來 用 們 生 到 作 地 於 出 就 分 對 成 會 可 主 發 年 動 同 工 也 能 下 過 子 說 產 種 面 而 方 後 多 定 行 學 法 所 民 得 經 十 三 之 進 著 等 部 度 家 電 力 裡 如 水 化 高 自 二 理 起 小 物 現 實 加 量 都 兩 體 制 機 當 使 點 從 業 本 去 把 性 好 應 開 它 合 還 因 由 其 些 然 前 外 天 政 四 日 那 社 義 事 平 形 相 全 表 間 樣 與 關 各 重 新 線 內 數 正 心 反 你 明 看 原 又 麼 利 比 或 但 質 氣 第 向 道 命 此 變 條 只 沒 結 解 問 意 建 月 公 無 系 軍 很 情 者 最 立 代 想 已 通 並 提 直 題 黨 程 展 五 果 料 象 員 革 位 入 常 文 總 次 品 式 活 設 及 管 特 件 長 求 老 頭 基 資 邊 流 路 級 少 圖 山 統 接 知 較 將 組 見 計 別 她 手 角 期 根 論 運 農 指 幾 九 區 強 放 決 西 被 幹 做 必 戰 先 回 則 任 取 據 處 隊 南 給 色 光 門 即 保 治 北 造 百 規 熱 領 七 海 口 東 導 器 壓 志 世 金 增 爭 濟 階 油 思 術 極 交 受 聯 什 認 六 共 權 收 證 改 清 美 再 採 轉 更 單 風 切 打 白 教 速 花 帶 安 場 身 車 例 真 務 具 萬 每 目 至 達 走 積 示 議 聲 報 鬥 完 類 八 離 華 名 確 才 科 張 信 馬 節 話 米 整 空 元 況 今 集 溫 傳 土 許 步 群 廣 石 記 需 段 研 界 拉 林 律 叫 且 究 觀 越 織 裝 影 算 低 持 音 眾 書 布 复 容 兒 須 際 商 非 驗 連 斷 深 難 近 礦 千 週 委 素 技 備 半 辦 青 省 列 習 響 約 支 般 史 感 勞 便 團 往 酸 歷 市 克 何 除 消 構 府 稱 太 準 精 值 號 率 族 維 劃 選 標 寫 存 候 毛 親 快 效 斯 院 查 江 型 眼 王 按 格 養 易 置 派 層 片 始 卻 專 狀 育 廠 京 識 適 屬 圓 包 火 住 調 滿 縣 局 照 參 紅 細 引 聽 該 鐵 價 嚴 首 底 液 官 德 隨 病 蘇 失 爾 死 講 配 女 黃 推 顯 談 罪 神 藝 呢 席 含 企 望 密 批 營 項 防 舉 球 英 氧 勢 告 李 台 落 木 幫 輪 破 亞 師 圍 注 遠 字 材 排 供 河 態 封 另 施 減 樹 溶 怎 止 案 言 士 均 武 固 葉 魚 波 視 僅 費 緊 愛 左 章 早 朝 害 續 輕 服 試 食 充 兵 源 判 護 司 足 某 練 差 致 板 田 降 黑 犯 負 擊 范 繼 興 似 餘 堅 曲 輸 修 故 城 夫 夠 送 筆 船 佔 右 財 吃 富 春 職 覺 漢 畫 功 巴 跟 雖 雜 飛 檢 吸 助 昇 陽 互 初 創 抗 考 投 壞 策 古 徑 換 未 跑 留 鋼 曾 端 責 站 簡 述 錢 副 盡 帝 射 草 衝 承 獨 令 限 阿 宣 環 雙 請 超 微 讓 控 州 良 軸 找 否 紀 益 依 優 頂 礎 載 倒 房 突 坐 粉 敵 略 客 袁 冷 勝 絕 析 塊 劑 測 絲 協 訴 念 陳 仍 羅 鹽 友 洋 錯 苦 夜 刑 移 頻 逐 靠 混 母 短 皮 終 聚 汽 村 雲 哪 既 距 衛 停 烈 央 察 燒 迅 境 若 印 洲 刻 括 激 孔 搞 甚 室 待 核 校 散 侵 吧 甲 遊 久 菜 味 舊 模 湖 貨 損 預 阻 毫 普 穩 乙 媽 植 息 擴 銀 語 揮 酒 守 拿 序 紙 醫 缺 雨 嗎 針 劉 啊 急 唱 誤 訓 願 審 附 獲 茶 鮮 糧 斤 孩 脫 硫 肥 善 龍 演 父 漸 血 歡 械 掌 歌 沙 剛 攻 謂 盾 討 晚 粒 亂 燃 矛 乎 殺 藥 寧 魯 貴 鐘 煤 讀 班 伯 香 介 迫 句 豐 培 握 蘭 擔 弦 蛋 沉 假 穿 執 答 樂 誰 順 煙 縮 徵 臉 喜 松 腳 困 異 免 背 星 福 買 染 井 概 慢 怕 磁 倍 祖 皇 促 靜 補 評 翻 肉 踐 尼 衣 寬 揚 棉 希 傷 操 垂 秋 宜 氫 套 督 振 架 亮 末 憲 慶 編 牛 觸 映 雷 銷 詩 座 居 抓 裂 胞 呼 娘 景 威 綠 晶 厚 盟 衡 雞 孫 延 危 膠 屋 鄉 臨 陸 顧 掉 呀 燈 歲 措 束 耐 劇 玉 趙 跳 哥 季 課 凱 胡 額 款 紹 卷 齊 偉 蒸 殖 永 宗 苗 川 爐 岩 弱 零 楊 奏 沿 露 桿 探 滑 鎮 飯 濃 航 懷 趕 庫 奪 伊 靈 稅 途 滅 賽 歸 召 鼓 播 盤 裁 險 康 唯 錄 菌 純 借 糖 蓋 橫 符 私 努 堂 域 槍 潤 幅 哈 竟 熟 蟲 澤 腦 壤 碳 歐 遍 側 寨 敢 徹 慮 斜 薄 庭 納 彈 飼 伸 折 麥 濕 暗 荷 瓦 塞 床 築 惡 戶 訪 塔 奇 透 梁 刀 旋 跡 卡 氯 遇 份 毒 泥 退 洗 擺 灰 彩 賣 耗 夏 擇 忙 銅 獻 硬 予 繁 圈 雪 函 亦 抽 篇 陣 陰 丁 尺 追 堆 雄 迎 泛 爸 樓 避 謀 噸 野 豬 旗 累 偏 典 館 索 秦 脂 潮 爺 豆 忽 托 驚 塑 遺 愈 朱 替 纖 粗 傾 尚 痛 楚 謝 奮 購 磨 君 池 旁 碎 骨 監 捕 弟 暴 割 貫 殊 釋 詞 亡 壁 頓 寶 午 塵 聞 揭 炮 殘 冬 橋 婦 警 綜 招 吳 付 浮 遭 徐 您 搖 谷 贊 箱 隔 訂 男 吹 園 紛 唐 敗 宋 玻 巨 耕 坦 榮 閉 灣 鍵 凡 駐 鍋 救 恩 剝 凝 鹼 齒 截 煉 麻 紡 禁 廢 盛 版 緩 淨 睛 昌 婚 涉 筒 嘴 插 岸 朗 莊 街 藏 姑 貿 腐 奴 啦 慣 乘 夥 恢 勻 紗 扎 辯 耳 彪 臣 億 璃 抵 脈 秀 薩 俄 網 舞 店 噴 縱 寸 汗 掛 洪 賀 閃 柬 爆 烯 津 稻 牆 軟 勇 像 滾 厘 蒙 芳 肯 坡 柱 盪 腿 儀 旅 尾 軋 冰 貢 登 黎 削 鑽 勒 逃 障 氨 郭 峰 幣 港 伏 軌 畝 畢 擦 莫 刺 浪 秘 援 株 健 售 股 島 甘 泡 睡 童 鑄 湯 閥 休 匯 舍 牧 繞 炸 哲 磷 績 朋 淡 尖 啟 陷 柴 呈 徒 顏 淚 稍 忘 泵 藍 拖 洞 授 鏡 辛 壯 鋒 貧 虛 彎 摩 泰 幼 廷 尊 窗 綱 弄 隸 疑 氏 宮 姐 震 瑞 怪 尤 琴 循 描 膜 違 夾 腰 緣 珠 窮 森 枝 竹 溝 催 繩 憶 邦 剩 幸 漿 欄 擁 牙 貯 禮 濾 鈉 紋 罷 拍 咱 喊 袖 埃 勤 罰 焦 潛 伍 墨 欲 縫 姓 刊 飽 仿 獎 鋁 鬼 麗 跨 默 挖 鏈 掃 喝 袋 炭 污 幕 諸 弧 勵 梅 奶 潔 災 舟 鑑 苯 訟 抱 毀 懂 寒 智 埔 寄 屆 躍 渡 挑 丹 艱 貝 碰 拔 爹 戴 碼 夢 芽 熔 赤 漁 哭 敬 顆 奔 鉛 仲 虎 稀 妹 乏 珍 申 桌 遵 允 隆 螺 倉 魏 銳 曉 氮 兼 隱 礙 赫 撥 忠 肅 缸 牽 搶 博 巧 殼 兄 杜 訊 誠 碧 祥 柯 頁 巡 矩 悲 灌 齡 倫 票 尋 桂 鋪 聖 恐 恰 鄭 趣 抬 荒 騰 貼 柔 滴 猛 闊 輛 妻 填 撤 儲 簽 鬧 擾 紫 砂 遞 戲 吊 陶 伐 餵 療 瓶 婆 撫 臂 摸 忍 蝦 蠟 鄰 胸 鞏 擠 偶 棄 槽 勁 乳 鄧 吉 仁 爛 磚 租 烏 艦 伴 瓜 淺 丙 暫 燥 橡 柳 迷 暖 牌 秧 膽 詳 簧 踏 瓷 譜 呆 賓 糊 洛 輝 憤 競 隙 怒 粘 乃 緒 肩 籍 敏 塗 熙 皆 偵 懸 掘 享 糾 醒 狂 鎖 淀 恨 牲 霸 爬 賞 逆 玩 陵 祝 秒 浙 貌 役 彼 悉 鴨 趨 鳳 晨 畜 輩 秩 卵 署 梯 炎 灘 棋 驅 篩 峽 冒 啥 壽 譯 浸 泉 帽 遲 矽 疆 貸 漏 稿 冠 嫩 脅 芯 牢 叛 蝕 奧 鳴 嶺 羊 憑 串 塘 繪 酵 融 盆 錫 廟 籌 凍 輔 攝 襲 筋 拒 僚 旱 鉀 鳥 漆 沈 眉 疏 添 棒 穗 硝 韓 逼 扭 僑 涼 挺 碗 栽 炒 杯 患 餾 勸 豪 遼 勃 鴻 旦 吏 拜 狗 埋 輥 掩 飲 搬 罵 辭 勾 扣 估 蔣 絨 霧 丈 朵 姆 擬 宇 輯 陝 雕 償 蓄 崇 剪 倡 廳 咬 駛 薯 刷 斥 番 賦 奉 佛 澆 漫 曼 扇 鈣 桃 扶 仔 返 俗 虧 腔 鞋 棱 覆 框 悄 叔 撞 騙 勘 旺 沸 孤 吐 孟 渠 屈 疾 妙 惜 仰 狠 脹 諧 拋 黴 桑 崗 嘛 衰 盜 滲 臟 賴 湧 甜 曹 閱 肌 哩 厲 烴 緯 毅 昨 偽 症 煮 嘆 釘 搭 莖 籠 酷 偷 弓 錐 恆 傑 坑 鼻 翼 綸 敘 獄 逮 罐 絡 棚 抑 膨 蔬 寺 驟 穆 冶 枯 冊 屍 凸 紳 坯 犧 焰 轟 欣 晉 瘦 禦 錠 錦 喪 旬 鍛 壟 搜 撲 邀 亭 酯 邁 舒 脆 酶 閒 憂 酚 頑 羽 漲 卸 仗 陪 闢 懲 杭 姚 肚 捉 飄 漂 昆 欺 吾 郎 烷 汁 呵 飾 蕭 雅 郵 遷 燕 撒 姻 赴 宴 煩 債 帳 斑 鈴 旨 醇 董 餅 雛 姿 拌 傅 腹 妥 揉 賢 拆 歪 葡 胺 丟 浩 徽 昂 墊 擋 覽 貪 慰 繳 汪 慌 馮 諾 姜 誼 兇 劣 誣 耀 昏 躺 盈 騎 喬 溪 叢 盧 抹 悶 諮 刮 駕 纜 悟 摘 鉺 擲 頗 幻 柄 惠 慘 佳 仇 臘 窩 滌 劍 瞧 堡 潑 蔥 罩 霍 撈 胎 蒼 濱 倆 捅 湘 砍 霞 邵 萄 瘋 淮 遂 熊 糞 烘 宿 檔 戈 駁 嫂 裕 徙 箭 捐 腸 撐 曬 辨 殿 蓮 攤 攪 醬 屏 疫 哀 蔡 堵 沫 皺 暢 疊 閣 萊 敲 轄 鉤 痕 壩 巷 餓 禍 丘 玄 溜 曰 邏 彭 嘗 卿 妨 艇 吞 韋 怨 矮 歇)
declare -a french=(abaisser abandon abdiquer abeille abolir aborder aboutir aboyer abrasif abreuver abriter abroger abrupt absence absolu absurde abusif abyssal académie acajou acarien accabler accepter acclamer accolade accroche accuser acerbe achat acheter aciduler acier acompte acquérir acronyme acteur actif actuel adepte adéquat adhésif adjectif adjuger admettre admirer adopter adorer adoucir adresse adroit adulte adverbe aérer aéronef affaire affecter affiche affreux affubler agacer agencer agile agiter agrafer agréable agrume aider aiguille ailier aimable aisance ajouter ajuster alarmer alchimie alerte algèbre algue aliéner aliment alléger alliage allouer allumer alourdir alpaga altesse alvéole amateur ambigu ambre aménager amertume amidon amiral amorcer amour amovible amphibie ampleur amusant analyse anaphore anarchie anatomie ancien anéantir angle angoisse anguleux animal annexer annonce annuel anodin anomalie anonyme anormal antenne antidote anxieux apaiser apéritif aplanir apologie appareil appeler apporter appuyer aquarium aqueduc arbitre arbuste ardeur ardoise argent arlequin armature armement armoire armure arpenter arracher arriver arroser arsenic artériel article aspect asphalte aspirer assaut asservir assiette associer assurer asticot astre astuce atelier atome atrium atroce attaque attentif attirer attraper aubaine auberge audace audible augurer aurore automne autruche avaler avancer avarice avenir averse aveugle aviateur avide avion aviser avoine avouer avril axial axiome badge bafouer bagage baguette baignade balancer balcon baleine balisage bambin bancaire bandage banlieue bannière banquier barbier baril baron barque barrage bassin bastion bataille bateau batterie baudrier bavarder belette bélier belote bénéfice berceau berger berline bermuda besace besogne bétail beurre biberon bicycle bidule bijou bilan bilingue billard binaire biologie biopsie biotype biscuit bison bistouri bitume bizarre blafard blague blanchir blessant blinder blond bloquer blouson bobard bobine boire boiser bolide bonbon bondir bonheur bonifier bonus bordure borne botte boucle boueux bougie boulon bouquin bourse boussole boutique boxeur branche brasier brave brebis brèche breuvage bricoler brigade brillant brioche brique brochure broder bronzer brousse broyeur brume brusque brutal bruyant buffle buisson bulletin bureau burin bustier butiner butoir buvable buvette cabanon cabine cachette cadeau cadre caféine caillou caisson calculer calepin calibre calmer calomnie calvaire camarade caméra camion campagne canal caneton canon cantine canular capable caporal caprice capsule capter capuche carabine carbone caresser caribou carnage carotte carreau carton cascade casier casque cassure causer caution cavalier caverne caviar cédille ceinture céleste cellule cendrier censurer central cercle cérébral cerise cerner cerveau cesser chagrin chaise chaleur chambre chance chapitre charbon chasseur chaton chausson chavirer chemise chenille chéquier chercher cheval chien chiffre chignon chimère chiot chlorure chocolat choisir chose chouette chrome chute cigare cigogne cimenter cinéma cintrer circuler cirer cirque citerne citoyen citron civil clairon clameur claquer classe clavier client cligner climat clivage cloche clonage cloporte cobalt cobra cocasse cocotier coder codifier coffre cogner cohésion coiffer coincer colère colibri colline colmater colonel combat comédie commande compact concert conduire confier congeler connoter consonne contact convexe copain copie corail corbeau cordage corniche corpus correct cortège cosmique costume coton coude coupure courage couteau couvrir coyote crabe crainte cravate crayon créature créditer crémeux creuser crevette cribler crier cristal critère croire croquer crotale crucial cruel crypter cubique cueillir cuillère cuisine cuivre culminer cultiver cumuler cupide curatif curseur cyanure cycle cylindre cynique daigner damier danger danseur dauphin débattre débiter déborder débrider débutant décaler décembre déchirer décider déclarer décorer décrire décupler dédale déductif déesse défensif défiler défrayer dégager dégivrer déglutir dégrafer déjeuner délice déloger demander demeurer démolir dénicher dénouer dentelle dénuder départ dépenser déphaser déplacer déposer déranger dérober désastre descente désert désigner désobéir dessiner destrier détacher détester détourer détresse devancer devenir deviner devoir diable dialogue diamant dicter différer digérer digital digne diluer dimanche diminuer dioxyde directif diriger discuter disposer dissiper distance divertir diviser docile docteur dogme doigt domaine domicile dompter donateur donjon donner dopamine dortoir dorure dosage doseur dossier dotation douanier double douceur douter doyen dragon draper dresser dribbler droiture duperie duplexe durable durcir dynastie éblouir écarter écharpe échelle éclairer éclipse éclore écluse école économie écorce écouter écraser écrémer écrivain écrou écume écureuil édifier éduquer effacer effectif effigie effort effrayer effusion égaliser égarer éjecter élaborer élargir électron élégant éléphant élève éligible élitisme éloge élucider éluder emballer embellir embryon émeraude émission emmener émotion émouvoir empereur employer emporter emprise émulsion encadrer enchère enclave encoche endiguer endosser endroit enduire énergie enfance enfermer enfouir engager engin englober énigme enjamber enjeu enlever ennemi ennuyeux enrichir enrobage enseigne entasser entendre entier entourer entraver énumérer envahir enviable envoyer enzyme éolien épaissir épargne épatant épaule épicerie épidémie épier épilogue épine épisode épitaphe époque épreuve éprouver épuisant équerre équipe ériger érosion erreur éruption escalier espadon espèce espiègle espoir esprit esquiver essayer essence essieu essorer estime estomac estrade étagère étaler étanche étatique éteindre étendoir éternel éthanol éthique ethnie étirer étoffer étoile étonnant étourdir étrange étroit étude euphorie évaluer évasion éventail évidence éviter évolutif évoquer exact exagérer exaucer exceller excitant exclusif excuse exécuter exemple exercer exhaler exhorter exigence exiler exister exotique expédier explorer exposer exprimer exquis extensif extraire exulter fable fabuleux facette facile facture faiblir falaise fameux famille farceur farfelu farine farouche fasciner fatal fatigue faucon fautif faveur favori fébrile féconder fédérer félin femme fémur fendoir féodal fermer féroce ferveur festival feuille feutre février fiasco ficeler fictif fidèle figure filature filetage filière filleul filmer filou filtrer financer finir fiole firme fissure fixer flairer flamme flasque flatteur fléau flèche fleur flexion flocon flore fluctuer fluide fluvial folie fonderie fongible fontaine forcer forgeron formuler fortune fossile foudre fougère fouiller foulure fourmi fragile fraise franchir frapper frayeur frégate freiner frelon frémir frénésie frère friable friction frisson frivole froid fromage frontal frotter fruit fugitif fuite fureur furieux furtif fusion futur gagner galaxie galerie gambader garantir gardien garnir garrigue gazelle gazon géant gélatine gélule gendarme général génie genou gentil géologie géomètre géranium germe gestuel geyser gibier gicler girafe givre glace glaive glisser globe gloire glorieux golfeur gomme gonfler gorge gorille goudron gouffre goulot goupille gourmand goutte graduel graffiti graine grand grappin gratuit gravir grenat griffure griller grimper grogner gronder grotte groupe gruger grutier gruyère guépard guerrier guide guimauve guitare gustatif gymnaste gyrostat habitude hachoir halte hameau hangar hanneton haricot harmonie harpon hasard hélium hématome herbe hérisson hermine héron hésiter heureux hiberner hibou hilarant histoire hiver homard hommage homogène honneur honorer honteux horde horizon horloge hormone horrible houleux housse hublot huileux humain humble humide humour hurler hydromel hygiène hymne hypnose idylle ignorer iguane illicite illusion image imbiber imiter immense immobile immuable impact impérial implorer imposer imprimer imputer incarner incendie incident incliner incolore indexer indice inductif inédit ineptie inexact infini infliger informer infusion ingérer inhaler inhiber injecter injure innocent inoculer inonder inscrire insecte insigne insolite inspirer instinct insulter intact intense intime intrigue intuitif inutile invasion inventer inviter invoquer ironique irradier irréel irriter isoler ivoire ivresse jaguar jaillir jambe janvier jardin jauger jaune javelot jetable jeton jeudi jeunesse joindre joncher jongler joueur jouissif journal jovial joyau joyeux jubiler jugement junior jupon juriste justice juteux juvénile kayak kimono kiosque label labial labourer lacérer lactose lagune laine laisser laitier lambeau lamelle lampe lanceur langage lanterne lapin largeur larme laurier lavabo lavoir lecture légal léger légume lessive lettre levier lexique lézard liasse libérer libre licence licorne liège lièvre ligature ligoter ligue limer limite limonade limpide linéaire lingot lionceau liquide lisière lister lithium litige littoral livreur logique lointain loisir lombric loterie louer lourd loutre louve loyal lubie lucide lucratif lueur lugubre luisant lumière lunaire lundi luron lutter luxueux machine magasin magenta magique maigre maillon maintien mairie maison majorer malaxer maléfice malheur malice mallette mammouth mandater maniable manquant manteau manuel marathon marbre marchand mardi maritime marqueur marron marteler mascotte massif matériel matière matraque maudire maussade mauve maximal méchant méconnu médaille médecin méditer méduse meilleur mélange mélodie membre mémoire menacer mener menhir mensonge mentor mercredi mérite merle messager mesure métal météore méthode métier meuble miauler microbe miette mignon migrer milieu million mimique mince minéral minimal minorer minute miracle miroiter missile mixte mobile moderne moelleux mondial moniteur monnaie monotone monstre montagne monument moqueur morceau morsure mortier moteur motif mouche moufle moulin mousson mouton mouvant multiple munition muraille murène murmure muscle muséum musicien mutation muter mutuel myriade myrtille mystère mythique nageur nappe narquois narrer natation nation nature naufrage nautique navire nébuleux nectar néfaste négation négliger négocier neige nerveux nettoyer neurone neutron neveu niche nickel nitrate niveau noble nocif nocturne noirceur noisette nomade nombreux nommer normatif notable notifier notoire nourrir nouveau novateur novembre novice nuage nuancer nuire nuisible numéro nuptial nuque nutritif obéir objectif obliger obscur observer obstacle obtenir obturer occasion occuper océan octobre octroyer octupler oculaire odeur odorant offenser officier offrir ogive oiseau oisillon olfactif olivier ombrage omettre onctueux onduler onéreux onirique opale opaque opérer opinion opportun opprimer opter optique orageux orange orbite ordonner oreille organe orgueil orifice ornement orque ortie osciller osmose ossature otarie ouragan ourson outil outrager ouvrage ovation oxyde oxygène ozone paisible palace palmarès palourde palper panache panda pangolin paniquer panneau panorama pantalon papaye papier papoter papyrus paradoxe parcelle paresse parfumer parler parole parrain parsemer partager parure parvenir passion pastèque paternel patience patron pavillon pavoiser payer paysage peigne peintre pelage pélican pelle pelouse peluche pendule pénétrer pénible pensif pénurie pépite péplum perdrix perforer période permuter perplexe persil perte peser pétale petit pétrir peuple pharaon phobie phoque photon phrase physique piano pictural pièce pierre pieuvre pilote pinceau pipette piquer pirogue piscine piston pivoter pixel pizza placard plafond plaisir planer plaque plastron plateau pleurer plexus pliage plomb plonger pluie plumage pochette poésie poète pointe poirier poisson poivre polaire policier pollen polygone pommade pompier ponctuel pondérer poney portique position posséder posture potager poteau potion pouce poulain poumon pourpre poussin pouvoir prairie pratique précieux prédire préfixe prélude prénom présence prétexte prévoir primitif prince prison priver problème procéder prodige profond progrès proie projeter prologue promener propre prospère protéger prouesse proverbe prudence pruneau psychose public puceron puiser pulpe pulsar punaise punitif pupitre purifier puzzle pyramide quasar querelle question quiétude quitter quotient racine raconter radieux ragondin raideur raisin ralentir rallonge ramasser rapide rasage ratisser ravager ravin rayonner réactif réagir réaliser réanimer recevoir réciter réclamer récolter recruter reculer recycler rédiger redouter refaire réflexe réformer refrain refuge régalien région réglage régulier réitérer rejeter rejouer relatif relever relief remarque remède remise remonter remplir remuer renard renfort renifler renoncer rentrer renvoi replier reporter reprise reptile requin réserve résineux résoudre respect rester résultat rétablir retenir réticule retomber retracer réunion réussir revanche revivre révolte révulsif richesse rideau rieur rigide rigoler rincer riposter risible risque rituel rival rivière rocheux romance rompre ronce rondin roseau rosier rotatif rotor rotule rouge rouille rouleau routine royaume ruban rubis ruche ruelle rugueux ruiner ruisseau ruser rustique rythme sabler saboter sabre sacoche safari sagesse saisir salade salive salon saluer samedi sanction sanglier sarcasme sardine saturer saugrenu saumon sauter sauvage savant savonner scalpel scandale scélérat scénario sceptre schéma science scinder score scrutin sculpter séance sécable sécher secouer sécréter sédatif séduire seigneur séjour sélectif semaine sembler semence séminal sénateur sensible sentence séparer séquence serein sergent sérieux serrure sérum service sésame sévir sevrage sextuple sidéral siècle siéger siffler sigle signal silence silicium simple sincère sinistre siphon sirop sismique situer skier social socle sodium soigneux soldat soleil solitude soluble sombre sommeil somnoler sonde songeur sonnette sonore sorcier sortir sosie sottise soucieux soudure souffle soulever soupape source soutirer souvenir spacieux spatial spécial sphère spiral stable station sternum stimulus stipuler strict studieux stupeur styliste sublime substrat subtil subvenir succès sucre suffixe suggérer suiveur sulfate superbe supplier surface suricate surmener surprise sursaut survie suspect syllabe symbole symétrie synapse syntaxe système tabac tablier tactile tailler talent talisman talonner tambour tamiser tangible tapis taquiner tarder tarif tartine tasse tatami tatouage taupe taureau taxer témoin temporel tenaille tendre teneur tenir tension terminer terne terrible tétine texte thème théorie thérapie thorax tibia tiède timide tirelire tiroir tissu titane titre tituber toboggan tolérant tomate tonique tonneau toponyme torche tordre tornade torpille torrent torse tortue totem toucher tournage tousser toxine traction trafic tragique trahir train trancher travail trèfle tremper trésor treuil triage tribunal tricoter trilogie triomphe tripler triturer trivial trombone tronc tropical troupeau tuile tulipe tumulte tunnel turbine tuteur tutoyer tuyau tympan typhon typique tyran ubuesque ultime ultrason unanime unifier union unique unitaire univers uranium urbain urticant usage usine usuel usure utile utopie vacarme vaccin vagabond vague vaillant vaincre vaisseau valable valise vallon valve vampire vanille vapeur varier vaseux vassal vaste vecteur vedette végétal véhicule veinard véloce vendredi vénérer venger venimeux ventouse verdure vérin vernir verrou verser vertu veston vétéran vétuste vexant vexer viaduc viande victoire vidange vidéo vignette vigueur vilain village vinaigre violon vipère virement virtuose virus visage viseur vision visqueux visuel vital vitesse viticole vitrine vivace vivipare vocation voguer voile voisin voiture volaille volcan voltiger volume vorace vortex voter vouloir voyage voyelle wagon xénon yacht zèbre zénith zeste zoologie)
declare -a japanese=(あいこくしん あいさつ あいだ あおぞら あかちゃん あきる あけがた あける あこがれる あさい あさひ あしあと あじわう あずかる あずき あそぶ あたえる あたためる あたりまえ あたる あつい あつかう あっしゅく あつまり あつめる あてな あてはまる あひる あぶら あぶる あふれる あまい あまど あまやかす あまり あみもの あめりか あやまる あゆむ あらいぐま あらし あらすじ あらためる あらゆる あらわす ありがとう あわせる あわてる あんい あんがい あんこ あんぜん あんてい あんない あんまり いいだす いおん いがい いがく いきおい いきなり いきもの いきる いくじ いくぶん いけばな いけん いこう いこく いこつ いさましい いさん いしき いじゅう いじょう いじわる いずみ いずれ いせい いせえび いせかい いせき いぜん いそうろう いそがしい いだい いだく いたずら いたみ いたりあ いちおう いちじ いちど いちば いちぶ いちりゅう いつか いっしゅん いっせい いっそう いったん いっち いってい いっぽう いてざ いてん いどう いとこ いない いなか いねむり いのち いのる いはつ いばる いはん いびき いひん いふく いへん いほう いみん いもうと いもたれ いもり いやがる いやす いよかん いよく いらい いらすと いりぐち いりょう いれい いれもの いれる いろえんぴつ いわい いわう いわかん いわば いわゆる いんげんまめ いんさつ いんしょう いんよう うえき うえる うおざ うがい うかぶ うかべる うきわ うくらいな うくれれ うけたまわる うけつけ うけとる うけもつ うける うごかす うごく うこん うさぎ うしなう うしろがみ うすい うすぎ うすぐらい うすめる うせつ うちあわせ うちがわ うちき うちゅう うっかり うつくしい うったえる うつる うどん うなぎ うなじ うなずく うなる うねる うのう うぶげ うぶごえ うまれる うめる うもう うやまう うよく うらがえす うらぐち うらない うりあげ うりきれ うるさい うれしい うれゆき うれる うろこ うわき うわさ うんこう うんちん うんてん うんどう えいえん えいが えいきょう えいご えいせい えいぶん えいよう えいわ えおり えがお えがく えきたい えくせる えしゃく えすて えつらん えのぐ えほうまき えほん えまき えもじ えもの えらい えらぶ えりあ えんえん えんかい えんぎ えんげき えんしゅう えんぜつ えんそく えんちょう えんとつ おいかける おいこす おいしい おいつく おうえん おうさま おうじ おうせつ おうたい おうふく おうべい おうよう おえる おおい おおう おおどおり おおや おおよそ おかえり おかず おがむ おかわり おぎなう おきる おくさま おくじょう おくりがな おくる おくれる おこす おこなう おこる おさえる おさない おさめる おしいれ おしえる おじぎ おじさん おしゃれ おそらく おそわる おたがい おたく おだやか おちつく おっと おつり おでかけ おとしもの おとなしい おどり おどろかす おばさん おまいり おめでとう おもいで おもう おもたい おもちゃ おやつ おやゆび およぼす おらんだ おろす おんがく おんけい おんしゃ おんせん おんだん おんちゅう おんどけい かあつ かいが がいき がいけん がいこう かいさつ かいしゃ かいすいよく かいぜん かいぞうど かいつう かいてん かいとう かいふく がいへき かいほう かいよう がいらい かいわ かえる かおり かかえる かがく かがし かがみ かくご かくとく かざる がぞう かたい かたち がちょう がっきゅう がっこう がっさん がっしょう かなざわし かのう がはく かぶか かほう かほご かまう かまぼこ かめれおん かゆい かようび からい かるい かろう かわく かわら がんか かんけい かんこう かんしゃ かんそう かんたん かんち がんばる きあい きあつ きいろ ぎいん きうい きうん きえる きおう きおく きおち きおん きかい きかく きかんしゃ ききて きくばり きくらげ きけんせい きこう きこえる きこく きさい きさく きさま きさらぎ ぎじかがく ぎしき ぎじたいけん ぎじにってい ぎじゅつしゃ きすう きせい きせき きせつ きそう きぞく きぞん きたえる きちょう きつえん ぎっちり きつつき きつね きてい きどう きどく きない きなが きなこ きぬごし きねん きのう きのした きはく きびしい きひん きふく きぶん きぼう きほん きまる きみつ きむずかしい きめる きもだめし きもち きもの きゃく きやく ぎゅうにく きよう きょうりゅう きらい きらく きりん きれい きれつ きろく ぎろん きわめる ぎんいろ きんかくじ きんじょ きんようび ぐあい くいず くうかん くうき くうぐん くうこう ぐうせい くうそう ぐうたら くうふく くうぼ くかん くきょう くげん ぐこう くさい くさき くさばな くさる くしゃみ くしょう くすのき くすりゆび くせげ くせん ぐたいてき くださる くたびれる くちこみ くちさき くつした ぐっすり くつろぐ くとうてん くどく くなん くねくね くのう くふう くみあわせ くみたてる くめる くやくしょ くらす くらべる くるま くれる くろう くわしい ぐんかん ぐんしょく ぐんたい ぐんて けあな けいかく けいけん けいこ けいさつ げいじゅつ けいたい げいのうじん けいれき けいろ けおとす けおりもの げきか げきげん げきだん げきちん げきとつ げきは げきやく げこう げこくじょう げざい けさき げざん けしき けしごむ けしょう げすと けたば けちゃっぷ けちらす けつあつ けつい けつえき けっこん けつじょ けっせき けってい けつまつ げつようび げつれい けつろん げどく けとばす けとる けなげ けなす けなみ けぬき げねつ けねん けはい げひん けぶかい げぼく けまり けみかる けむし けむり けもの けらい けろけろ けわしい けんい けんえつ けんお けんか げんき けんげん けんこう けんさく けんしゅう けんすう げんそう けんちく けんてい けんとう けんない けんにん げんぶつ けんま けんみん けんめい けんらん けんり こあくま こいぬ こいびと ごうい こうえん こうおん こうかん ごうきゅう ごうけい こうこう こうさい こうじ こうすい ごうせい こうそく こうたい こうちゃ こうつう こうてい こうどう こうない こうはい ごうほう ごうまん こうもく こうりつ こえる こおり ごかい ごがつ ごかん こくご こくさい こくとう こくない こくはく こぐま こけい こける ここのか こころ こさめ こしつ こすう こせい こせき こぜん こそだて こたい こたえる こたつ こちょう こっか こつこつ こつばん こつぶ こてい こてん ことがら ことし ことば ことり こなごな こねこね このまま このみ このよ ごはん こひつじ こふう こふん こぼれる ごまあぶら こまかい ごますり こまつな こまる こむぎこ こもじ こもち こもの こもん こやく こやま こゆう こゆび こよい こよう こりる これくしょん ころっけ こわもて こわれる こんいん こんかい こんき こんしゅう こんすい こんだて こんとん こんなん こんびに こんぽん こんまけ こんや こんれい こんわく ざいえき さいかい さいきん ざいげん ざいこ さいしょ さいせい ざいたく ざいちゅう さいてき ざいりょう さうな さかいし さがす さかな さかみち さがる さぎょう さくし さくひん さくら さこく さこつ さずかる ざせき さたん さつえい ざつおん ざっか ざつがく さっきょく ざっし さつじん ざっそう さつたば さつまいも さてい さといも さとう さとおや さとし さとる さのう さばく さびしい さべつ さほう さほど さます さみしい さみだれ さむけ さめる さやえんどう さゆう さよう さよく さらだ ざるそば さわやか さわる さんいん さんか さんきゃく さんこう さんさい ざんしょ さんすう さんせい さんそ さんち さんま さんみ さんらん しあい しあげ しあさって しあわせ しいく しいん しうち しえい しおけ しかい しかく じかん しごと しすう じだい したうけ したぎ したて したみ しちょう しちりん しっかり しつじ しつもん してい してき してつ じてん じどう しなぎれ しなもの しなん しねま しねん しのぐ しのぶ しはい しばかり しはつ しはらい しはん しひょう しふく じぶん しへい しほう しほん しまう しまる しみん しむける じむしょ しめい しめる しもん しゃいん しゃうん しゃおん じゃがいも しやくしょ しゃくほう しゃけん しゃこ しゃざい しゃしん しゃせん しゃそう しゃたい しゃちょう しゃっきん じゃま しゃりん しゃれい じゆう じゅうしょ しゅくはく じゅしん しゅっせき しゅみ しゅらば じゅんばん しょうかい しょくたく しょっけん しょどう しょもつ しらせる しらべる しんか しんこう じんじゃ しんせいじ しんちく しんりん すあげ すあし すあな ずあん すいえい すいか すいとう ずいぶん すいようび すうがく すうじつ すうせん すおどり すきま すくう すくない すける すごい すこし ずさん すずしい すすむ すすめる すっかり ずっしり ずっと すてき すてる すねる すのこ すはだ すばらしい ずひょう ずぶぬれ すぶり すふれ すべて すべる ずほう すぼん すまい すめし すもう すやき すらすら するめ すれちがう すろっと すわる すんぜん すんぽう せあぶら せいかつ せいげん せいじ せいよう せおう せかいかん せきにん せきむ せきゆ せきらんうん せけん せこう せすじ せたい せたけ せっかく せっきゃく ぜっく せっけん せっこつ せっさたくま せつぞく せつだん せつでん せっぱん せつび せつぶん せつめい せつりつ せなか せのび せはば せびろ せぼね せまい せまる せめる せもたれ せりふ ぜんあく せんい せんえい せんか せんきょ せんく せんげん ぜんご せんさい せんしゅ せんすい せんせい せんぞ せんたく せんちょう せんてい せんとう せんぬき せんねん せんぱい ぜんぶ ぜんぽう せんむ せんめんじょ せんもん せんやく せんゆう せんよう ぜんら ぜんりゃく せんれい せんろ そあく そいとげる そいね そうがんきょう そうき そうご そうしん そうだん そうなん そうび そうめん そうり そえもの そえん そがい そげき そこう そこそこ そざい そしな そせい そせん そそぐ そだてる そつう そつえん そっかん そつぎょう そっけつ そっこう そっせん そっと そとがわ そとづら そなえる そなた そふぼ そぼく そぼろ そまつ そまる そむく そむりえ そめる そもそも そよかぜ そらまめ そろう そんかい そんけい そんざい そんしつ そんぞく そんちょう ぞんび ぞんぶん そんみん たあい たいいん たいうん たいえき たいおう だいがく たいき たいぐう たいけん たいこ たいざい だいじょうぶ だいすき たいせつ たいそう だいたい たいちょう たいてい だいどころ たいない たいねつ たいのう たいはん だいひょう たいふう たいへん たいほ たいまつばな たいみんぐ たいむ たいめん たいやき たいよう たいら たいりょく たいる たいわん たうえ たえる たおす たおる たおれる たかい たかね たきび たくさん たこく たこやき たさい たしざん だじゃれ たすける たずさわる たそがれ たたかう たたく ただしい たたみ たちばな だっかい だっきゃく だっこ だっしゅつ だったい たてる たとえる たなばた たにん たぬき たのしみ たはつ たぶん たべる たぼう たまご たまる だむる ためいき ためす ためる たもつ たやすい たよる たらす たりきほんがん たりょう たりる たると たれる たれんと たろっと たわむれる だんあつ たんい たんおん たんか たんき たんけん たんご たんさん たんじょうび だんせい たんそく たんたい だんち たんてい たんとう だんな たんにん だんねつ たんのう たんぴん だんぼう たんまつ たんめい だんれつ だんろ だんわ ちあい ちあん ちいき ちいさい ちえん ちかい ちから ちきゅう ちきん ちけいず ちけん ちこく ちさい ちしき ちしりょう ちせい ちそう ちたい ちたん ちちおや ちつじょ ちてき ちてん ちぬき ちぬり ちのう ちひょう ちへいせん ちほう ちまた ちみつ ちみどろ ちめいど ちゃんこなべ ちゅうい ちゆりょく ちょうし ちょさくけん ちらし ちらみ ちりがみ ちりょう ちるど ちわわ ちんたい ちんもく ついか ついたち つうか つうじょう つうはん つうわ つかう つかれる つくね つくる つけね つける つごう つたえる つづく つつじ つつむ つとめる つながる つなみ つねづね つのる つぶす つまらない つまる つみき つめたい つもり つもる つよい つるぼ つるみく つわもの つわり てあし てあて てあみ ていおん ていか ていき ていけい ていこく ていさつ ていし ていせい ていたい ていど ていねい ていひょう ていへん ていぼう てうち ておくれ てきとう てくび でこぼこ てさぎょう てさげ てすり てそう てちがい てちょう てつがく てつづき でっぱ てつぼう てつや でぬかえ てぬき てぬぐい てのひら てはい てぶくろ てふだ てほどき てほん てまえ てまきずし てみじか てみやげ てらす てれび てわけ てわたし でんあつ てんいん てんかい てんき てんぐ てんけん てんごく てんさい てんし てんすう でんち てんてき てんとう てんない てんぷら てんぼうだい てんめつ てんらんかい でんりょく でんわ どあい といれ どうかん とうきゅう どうぐ とうし とうむぎ とおい とおか とおく とおす とおる とかい とかす ときおり ときどき とくい とくしゅう とくてん とくに とくべつ とけい とける とこや とさか としょかん とそう とたん とちゅう とっきゅう とっくん とつぜん とつにゅう とどける ととのえる とない となえる となり とのさま とばす どぶがわ とほう とまる とめる ともだち ともる どようび とらえる とんかつ どんぶり ないかく ないこう ないしょ ないす ないせん ないそう なおす ながい なくす なげる なこうど なさけ なたでここ なっとう なつやすみ ななおし なにごと なにもの なにわ なのか なふだ なまいき なまえ なまみ なみだ なめらか なめる なやむ ならう ならび ならぶ なれる なわとび なわばり にあう にいがた にうけ におい にかい にがて にきび にくしみ にくまん にげる にさんかたんそ にしき にせもの にちじょう にちようび にっか にっき にっけい にっこう にっさん にっしょく にっすう にっせき にってい になう にほん にまめ にもつ にやり にゅういん にりんしゃ にわとり にんい にんか にんき にんげん にんしき にんずう にんそう にんたい にんち にんてい にんにく にんぷ にんまり にんむ にんめい にんよう ぬいくぎ ぬかす ぬぐいとる ぬぐう ぬくもり ぬすむ ぬまえび ぬめり ぬらす ぬんちゃく ねあげ ねいき ねいる ねいろ ねぐせ ねくたい ねくら ねこぜ ねこむ ねさげ ねすごす ねそべる ねだん ねつい ねっしん ねつぞう ねったいぎょ ねぶそく ねふだ ねぼう ねほりはほり ねまき ねまわし ねみみ ねむい ねむたい ねもと ねらう ねわざ ねんいり ねんおし ねんかん ねんきん ねんぐ ねんざ ねんし ねんちゃく ねんど ねんぴ ねんぶつ ねんまつ ねんりょう ねんれい のいず のおづま のがす のきなみ のこぎり のこす のこる のせる のぞく のぞむ のたまう のちほど のっく のばす のはら のべる のぼる のみもの のやま のらいぬ のらねこ のりもの のりゆき のれん のんき ばあい はあく ばあさん ばいか ばいく はいけん はいご はいしん はいすい はいせん はいそう はいち ばいばい はいれつ はえる はおる はかい ばかり はかる はくしゅ はけん はこぶ はさみ はさん はしご ばしょ はしる はせる ぱそこん はそん はたん はちみつ はつおん はっかく はづき はっきり はっくつ はっけん はっこう はっさん はっしん はったつ はっちゅう はってん はっぴょう はっぽう はなす はなび はにかむ はぶらし はみがき はむかう はめつ はやい はやし はらう はろうぃん はわい はんい はんえい はんおん はんかく はんきょう ばんぐみ はんこ はんしゃ はんすう はんだん ぱんち ぱんつ はんてい はんとし はんのう はんぱ はんぶん はんぺん はんぼうき はんめい はんらん はんろん ひいき ひうん ひえる ひかく ひかり ひかる ひかん ひくい ひけつ ひこうき ひこく ひさい ひさしぶり ひさん びじゅつかん ひしょ ひそか ひそむ ひたむき ひだり ひたる ひつぎ ひっこし ひっし ひつじゅひん ひっす ひつぜん ぴったり ぴっちり ひつよう ひてい ひとごみ ひなまつり ひなん ひねる ひはん ひびく ひひょう ひほう ひまわり ひまん ひみつ ひめい ひめじし ひやけ ひやす ひよう びょうき ひらがな ひらく ひりつ ひりょう ひるま ひるやすみ ひれい ひろい ひろう ひろき ひろゆき ひんかく ひんけつ ひんこん ひんしゅ ひんそう ぴんち ひんぱん びんぼう ふあん ふいうち ふうけい ふうせん ぷうたろう ふうとう ふうふ ふえる ふおん ふかい ふきん ふくざつ ふくぶくろ ふこう ふさい ふしぎ ふじみ ふすま ふせい ふせぐ ふそく ぶたにく ふたん ふちょう ふつう ふつか ふっかつ ふっき ふっこく ぶどう ふとる ふとん ふのう ふはい ふひょう ふへん ふまん ふみん ふめつ ふめん ふよう ふりこ ふりる ふるい ふんいき ぶんがく ぶんぐ ふんしつ ぶんせき ふんそう ぶんぽう へいあん へいおん へいがい へいき へいげん へいこう へいさ へいしゃ へいせつ へいそ へいたく へいてん へいねつ へいわ へきが へこむ べにいろ べにしょうが へらす へんかん べんきょう べんごし へんさい へんたい べんり ほあん ほいく ぼうぎょ ほうこく ほうそう ほうほう ほうもん ほうりつ ほえる ほおん ほかん ほきょう ぼきん ほくろ ほけつ ほけん ほこう ほこる ほしい ほしつ ほしゅ ほしょう ほせい ほそい ほそく ほたて ほたる ぽちぶくろ ほっきょく ほっさ ほったん ほとんど ほめる ほんい ほんき ほんけ ほんしつ ほんやく まいにち まかい まかせる まがる まける まこと まさつ まじめ ますく まぜる まつり まとめ まなぶ まぬけ まねく まほう まもる まゆげ まよう まろやか まわす まわり まわる まんが まんきつ まんぞく まんなか みいら みうち みえる みがく みかた みかん みけん みこん みじかい みすい みすえる みせる みっか みつかる みつける みてい みとめる みなと みなみかさい みねらる みのう みのがす みほん みもと みやげ みらい みりょく みわく みんか みんぞく むいか むえき むえん むかい むかう むかえ むかし むぎちゃ むける むげん むさぼる むしあつい むしば むじゅん むしろ むすう むすこ むすぶ むすめ むせる むせん むちゅう むなしい むのう むやみ むよう むらさき むりょう むろん めいあん めいうん めいえん めいかく めいきょく めいさい めいし めいそう めいぶつ めいれい めいわく めぐまれる めざす めした めずらしい めだつ めまい めやす めんきょ めんせき めんどう もうしあげる もうどうけん もえる もくし もくてき もくようび もちろん もどる もらう もんく もんだい やおや やける やさい やさしい やすい やすたろう やすみ やせる やそう やたい やちん やっと やっぱり やぶる やめる ややこしい やよい やわらかい ゆうき ゆうびんきょく ゆうべ ゆうめい ゆけつ ゆしゅつ ゆせん ゆそう ゆたか ゆちゃく ゆでる ゆにゅう ゆびわ ゆらい ゆれる ようい ようか ようきゅう ようじ ようす ようちえん よかぜ よかん よきん よくせい よくぼう よけい よごれる よさん よしゅう よそう よそく よっか よてい よどがわく よねつ よやく よゆう よろこぶ よろしい らいう らくがき らくご らくさつ らくだ らしんばん らせん らぞく らたい らっか られつ りえき りかい りきさく りきせつ りくぐん りくつ りけん りこう りせい りそう りそく りてん りねん りゆう りゅうがく りよう りょうり りょかん りょくちゃ りょこう りりく りれき りろん りんご るいけい るいさい るいじ るいせき るすばん るりがわら れいかん れいぎ れいせい れいぞうこ れいとう れいぼう れきし れきだい れんあい れんけい れんこん れんさい れんしゅう れんぞく れんらく ろうか ろうご ろうじん ろうそく ろくが ろこつ ろじうら ろしゅつ ろせん ろてん ろめん ろれつ ろんぎ ろんぱ ろんぶん ろんり わかす わかめ わかやま わかれる わしつ わじまし わすれもの わらう われる)

bip39_language() (
  shopt -s extglob
  case "${LANG::5}" in
    fr?(_*)) echo french ;;
    es?(_*)) echo spanish ;;
    zh_CN) echo chinese_simplified ;;
    zh_TW) echo chinese_traditional ;;
    pt?(_*)) echo portuguese ;;
    it?(_*)) echo italian ;;
    cs?(_*)) echo czech ;;
    ko?(_*)) echo korean ;;
    ja?(_*)) echo japanese ;;
    *) echo english ;;
  esac
)

check-mnemonic()
  if [[ $# =~ ^(12|15|18|21|24)$ ]]
  then
    local -n wordlist="$(bip39_language)"
    local -A wordlist_reverse
    local -i i
    for ((i=0; i<${#wordlist[@]}; i++))
    do wordlist_reverse[${wordlist[$i]}]=$((i+1))
    done

    local word dc_script='16o0'
    for word
    do
      if ((${wordlist_reverse[$word]}))
      then dc_script="$dc_script 2048*${wordlist_reverse[$word]} 1-+"
      else return 1
      fi
    done
    dc_script="$dc_script 2 $(($#*11/33))^ 0k/ p"
    create-mnemonic $(
      dc -e "$dc_script" |
      { read -r; printf "%$(($#*11*32/33/4))s" $REPLY; } |
      sed 's/ /0/g'
    ) |
    grep -q " ${@: -1}$" || return 2
  else return 3;
  fi

complete -W "${english[*]}" mnemonic-to-seed
function mnemonic-to-seed() {
  local o OPTIND 
  if getopts hpP o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-USAGE_3
	${FUNCNAME[0]} -h
	${FUNCNAME[@]} [-p|-P] [-b] word ...
	USAGE_3
        ;;
      p|P)
       if ! test -t 1
       then
         echo "stdout is not a terminal, cannot prompt passphrase" >&2
         return 1
       fi
       ;;&
      p)
        read -p "Passphrase: "
        BIP39_PASSPHRASE="$REPLY" ${FUNCNAME[0]} "$@"
        ;;
      P)
        local passphrase
        read -p "Passphrase:" -s passphrase
        read -p "Confirm passphrase:" -s
        if [[ "$REPLY" = "$passphrase" ]]
        then BIP39_PASSPHRASE=$passphrase $FUNCNAME "$@"
        else echo "passphrase input error" >&2; return 3;
        fi
        ;;
    esac
  else
    check-mnemonic "$@"
    case "$?" in
      1) echo "WARNING: unreckognized word in mnemonic." >&2 ;;&
      2) echo "WARNING: wrong mnemonic checksum."        >&2 ;;&
      3) echo "WARNING: unexpected number of words."     >&2 ;;&
      *) openssl kdf -keylen 64 -kdfopt digest:SHA512 \
	  -kdfopt pass:"$*" \
	  -kdfopt salt:"mnemonic$BIP39_PASSPHRASE" \
	  -kdfopt iter:2048 -binary \
	  PBKDF2 |
	  if [[ -t 1 ]]
	  then cat -v
	  else cat
	  fi
	;;
    esac
  fi
}

function create-mnemonic() {
  local -n wordlist="$(bip39_language)"
  local OPTIND OPTARG o
  if getopts h o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-USAGE
	${FUNCNAME[@]} -h
	${FUNCNAME[@]} entropy-size
	USAGE
        ;;
    esac
  elif (( ${#wordlist[@]} != 2048 ))
  then
    1>&2 echo "unexpected number of words (${#wordlist[@]}) in wordlist array"
    return 2
  elif [[ $1 =~ ^(128|160|192|224|256)$ ]]
  then $FUNCNAME $(openssl rand -hex $(($1/8)))
  elif [[ "$1" =~ ^([[:xdigit:]]{2}){16,32}$ ]]
  then
    local hexnoise="${1^^}"
    local -i ENT=${#hexnoise}*4 #bits
    if ((ENT % 32))
    then
      1>&2 echo entropy must be a multiple of 32, yet it is $ENT
      return 2
    fi
    { 
      # "A checksum is generated by taking the first <pre>ENT / 32</pre> bits
      # of its SHA256 hash"
      local -i CS=ENT/32
      local -i MS=(ENT+CS)/11 #bits
      #1>&2 echo $ENT $CS $MS
      echo "$MS 1- sn16doi"
      echo "$hexnoise 2 $CS^*"
      echo -n "${hexnoise^^[a-f]}" |
      basenc --base16 -d |
      openssl dgst -sha256 -binary |
      head -c1 |
      basenc --base16
      echo "0k 2 8 $CS -^/+"
      echo "[800 ~r ln1-dsn0<x]dsxx Aof"
    } |
    dc |
    while read -r
    do echo ${wordlist[REPLY]}
    done |
    {
      mapfile -t
      echo "${MAPFILE[*]}"
    } |
    if [[ "$LANG" =~ ^zh_ ]]
    then sed 's/ //g'
    else cat
    fi
  elif (($# == 0))
  then $FUNCNAME 160
  else
    1>&2 echo parameters have insufficient entropy or wrong format
    return 4
  fi
}

# bip-0039 code stops here }}}

p2pkh-address() {
  {
    printf %b "${P2PKH_PREFIX:-\x00}"
    cat
  } | base58 -c
}
 
bitcoinAddress() (
  shopt -s extglob
  local OPTIND o
  if getopts ht o
  then shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE_bitcoinAddress
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} PUBLIC_POINT
	${FUNCNAME[0]} WIF_PRIVATE_KEY
	${FUNCNAME[0]} PUBLIC_EXTENDED_KEY
	END_USAGE_bitcoinAddress
        ;;
      t) P2PKH_PREFIX="\x6F" ${FUNCNAME[0]} "$@" ;;
    esac
  elif [[ "$1" =~ ^0([23]([[:xdigit:]]{2}){32}|4([[:xdigit:]]{2}){64})$ ]]
  then basenc --base16 -d <<<"${1^^[a-f]}" |hash160 | p2pkh-address 
  elif
    base58 -v <<<"$1" && 
    [[ "$(base58 -d <<<"$1" |
    basenc --base16 -w76
    )" =~ ^(80|ef)([[:xdigit:]]{64})(01)?([[:xdigit:]]{8})$ ]]
  then
    {
      echo "$secp256k1 16doi lgx ${BASH_REMATCH[2]^^}l;xlfxl<*+"
      if test -n "${BASH_REMATCH[3]}"
      then echo lCx
      else echo lUx
      fi
      echo P
    } |
    dc |
    basenc --base16 -w130 |
    {
      read
      if [[ "${BASH_REMATCH[1]}" = 80 ]]
      then ${FUNCNAME[0]} "$REPLY"
      else ${FUNCNAME[0]} -t "$REPLY"
      fi
    }
  elif [[ "$1" =~ ^[xtyzv]pub ]] && base58 -v <<<"$1"
  then
    base58 -d <<<"$1" |
    head -c -4 |
    tail -c 33 |
    basenc --base16 -w0 |
    {
      read
      case "${1::1}" in
        x) ${FUNCNAME[0]} "$REPLY" ;;
        t) ${FUNCNAME[0]} -t "$REPLY" ;;
        y) 
          {
            printf %b "\x05"
            {
              printf %b%b "\x00\x14"
              echo "${REPLY^^[a-f]}" | basenc --base16 -d |
              hash160
            } | 
            hash160
          } | base58 -c
          ;;
        z) segwitAddress -p "$REPLY" ;;
        v) segwitAddress -t -p "$REPLY" ;;
        *)
          echo "${1::4} addresses NYI" >&2
          return 2
          ;;
      esac
    }
  else return 1
  fi
)

# vi: ft=bash
