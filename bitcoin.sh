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

if [[ ! -v secp256k1 ]]
then
  declare -r secp256k1="
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
fi

# This file requires extended globs to be parsed
shopt -s extglob

hash160() {
  openssl dgst -sha256 -binary | 
  openssl dgst -rmd160 -binary
# The code below was a temporary fix
# that does not seem to be necessary anymore (oct. 2023)
#  {
#    # https://github.com/openssl/openssl/issues/16994
#    # "-provider legacy" for openssl 3.0 || fallback for old versions
#    2>/dev/null openssl dgst -provider legacy -rmd160 -binary ||
#    openssl dgst -rmd160 -binary
#  }
}

escape-output-if-needed()
  if test -t 1
  then cat -v
  else cat
  fi

ser32()
  if
    local -i i=$1
    ((i >= 0 && i < 1<<32)) 
  then
    printf "%08X" $i |
    basenc --base16 -d
  else return 1
  fi

ser256()
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{65,})$ ]]
  then echo "unexpectedly large parameter" >&2; return 1
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{64})$ ]]
  then basenc --base16 -d <<<"${BASH_REMATCH[2]^^[a-f]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,63})$ ]]
  then $FUNCNAME "0x0${BASH_REMATCH[2]}"
  else return 1
  fi

base58()
  if
    local base58_chars="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
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
        read -r < "${1:-/dev/stdin}"
        if [[ "$REPLY" =~ ^(1*)([$base58_chars]+)$ ]]
        then
	  dc -e "${BASH_REMATCH[1]//1/0P}
	  0${base58_chars//?/ds&1+} 0${BASH_REMATCH[2]//?/ 58*l&+}P" |
          escape-output-if-needed
        else return 1
        fi        ;;
      v)
        tee >(${FUNCNAME[0]} -d "$@" |head -c -4 |${FUNCNAME[0]} -c) |
        uniq -d | read 
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
    basenc --base16 "${1:-/dev/stdin}" -w0 |
    if
      read
      [[ $REPLY =~ ^(0{2}*)([[:xdigit:]]{2}*) ]]
      echo -n "${BASH_REMATCH[1]//00/1}"
      (( ${#BASH_REMATCH[2]} > 0 ))
    then
      dc -e "16i0${BASH_REMATCH[2]^^} Ai[58~rd0<x]dsxx+f" |
      while read -r
      do echo -n "${base58_chars:REPLY:1}"
      done
    fi
    echo
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

if [[ ! -v bech32_charset ]]
then
  declare -r bech32_charset="qpzry9x8gf2tvdw0s3jn54khce6mua7l"
  declare -Ai bech32_charset_reverse
  for i in {0..31}
  do bech32_charset_reverse[${bech32_charset:i:1}]=i
  done
fi

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
    echo -n "${hrp}1$data"
    bech32_create_checksum "$hrp" $(
      echo -n "$data" |
      while read -n 1
      do echo "${bech32_charset_reverse[REPLY]}"
      done
    )
  fi

polymod() {
  local -ai generator=(0x{3b6a57b2,26508e6d,1ea119fa,3d4233dd,2a1462b3})
  local -i chk=1 value
  for value
  do
    local -i top i
    (( top = chk >> 25, chk = (chk & 0x1ffffff) << 5 ^ value ))
    for i in {0..4}
    do (( ((top >> i) & 1) && (chk^=generator[i]) ))
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
  (( pmod == ${BECH32_CONST:-1} ))
}

bech32_create_checksum() {
  local hrp="$1"
  shift
  local -i p mod=$(polymod $(hrpExpand "$hrp") "$@" 0 0 0 0 0 0)^${BECH32_CONST:-1}
  for p in {0..5}
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
    set - "$@" $(bech32_create_checksum "$hrp" "$@")
    echo -n "${hrp}1"
    for i
    do echo -n "${bech32_charset:i:1}"
    done
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
    local -i version=WITNESS_VERSION
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

segwit_verify()
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

convertbits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  local -i maxv=$(( (1 << outbits) - 1 ))
  while read 
  do
    ((
      val=(val<<inbits)|REPLY,
      bits+=inbits
    ))
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
  elif (( ( (val << (outbits - bits) ) & maxv ) || bits >= inbits))
  then return 1
  fi
}

segwit_decode()
  if
    test-addr() {
      bech32_decode "$addr" ||
      bech32_decode -m "$addr" 
    }
    local addr="$1"
    ! test-addr >/dev/null
  then return 1
  else
    test-addr |
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

bip32()
  if
    local header_format='%08X%02X%08X%08X' 
    local OPTIND OPTARG o
    getopts hst o
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
                read key < <(
		  dc <<<"$secp256k1 4d*doilgx${key^^}l;xlex"
		)
            esac
            ;;
          +([[:digit:]])h)
            (( child_number= ${operator%h} + (1 << 31) ))
            ;&
          +([[:digit:]]))

            ((depth++))
            local parent_id
            if [[ ! "$operator" =~ h$ ]]
            then child_number=operator
            fi

            if isPrivate "$version"
            then # CKDpriv
	      read parent_id < <(dc <<<"$secp256k1 4d*doilgx${key^^}l;xlex")
	      {
		read key
		read chain_code
	      } < <(
		{
		  echo "$secp256k1"
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
		  echo rp
		} | dc
	      )

            elif isPublic "$version"
            then # CKDpub
              parent_id="$key"
              if (( child_number >= (1 << 31) ))
              then
                echo "extented public key can't produce a hardened child" >&2
                return 4
              else
		{
		  read key
		  read chain_code
		} < <(
		  {
		    echo "$secp256k1"
		    {
		      basenc --base16 -d <<<"${key^^[a-f]}"
		      ser32 $child_number
		    } |
		    openssl dgst -sha512 -mac hmac -macopt hexkey:"$chain_code" -binary |
		    basenc --base16 -w64 |
		    {
		       read left
		       read right
		       echo "8d+doi$right lgx$left l;x ${key^^}l>x l<~rljx lPxlexp"
		    }
		  } | dc
		)
              fi
            else
              echo "version is neither private nor public?!" >&2
              return 111
            fi
            while ((${#key} < 66))
            do key="0$key"
            done
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
      {
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
      } |
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
      escape-output-if-needed
      ;;
  esac
  
# bip-0039 code starts here {{{

bip39_words()
  case "${LANG::5}" in
    # lists of words from https://github.com/bitcoin/bips/tree/master/bip-0039
    fr?(_*)) echo a{b{a{isser,ndon},diquer,eille,o{lir,rder,utir,yer},r{asif,euver,iter,oger,upt},s{ence,olu,urde},usif,yssal},c{a{démie,jou,rien},c{abler,epter,lamer,olade,roche,user},erbe,h{at,eter},i{duler,er},ompte,quérir,ronyme,t{eur,if,uel}},d{epte,équat,hésif,j{ectif,uger},m{ettre,irer},o{pter,rer,ucir},r{esse,oit},ulte,verbe},ér{er,onef},ff{aire,ecter,iche,reux,ubler},g{acer,encer,i{le,ter},r{afer,éable,ume}},i{der,guille,lier,mable,sance},j{outer,uster},l{armer,chimie,erte,g{èbre,ue},i{éner,ment},l{éger,iage,ouer,umer},ourdir,paga,tesse,véole},m{ateur,b{igu,re},énager,ertume,i{don,ral},o{rcer,ur,vible},p{hibie,leur},usant},n{a{lyse,phore,rchie,tomie},cien,éantir,g{le,oisse,uleux},imal,n{exer,once,uel},o{din,malie,nyme,rmal},t{enne,idote},xieux},p{aiser,éritif,lanir,ologie,p{areil,eler,orter,uyer}},qu{arium,educ},r{b{itre,uste},d{eur,oise},gent,lequin,m{ature,ement,oire,ure},penter,r{acher,iver,oser},senic,t{ériel,icle}},s{p{ect,halte,irer},s{aut,ervir,iette,ocier,urer},t{icot,re,uce}},t{elier,ome,r{ium,oce},t{aque,entif,irer,raper}},u{b{aine,erge},d{ace,ible},gurer,rore,t{omne,ruche}},v{a{ler,ncer,rice},e{nir,rse,ugle},i{ateur,de,on,ser},o{ine,uer},ril},xi{al,ome}} b{a{dge,fouer,g{age,uette},ignade,l{ancer,con,eine,isage},mbin,n{caire,dage,lieue,nière,quier},r{bier,il,on,que,rage},s{sin,tion},t{aille,eau,terie},udrier,varder},elette,élier,elote,énéfice,e{r{ceau,ger,line,muda},s{ace,ogne}},étail,eurre,i{beron,cycle,dule,jou,l{an,ingue,lard},naire,o{logie,psie,type},s{cuit,on,touri},tume,zarre},l{a{fard,gue,nchir},essant,inder,o{nd,quer,uson}},o{b{ard,ine},i{re,ser},lide,n{bon,dir,heur,ifier,us},r{dure,ne},tte,u{cle,eux,gie,lon,quin,rse,ssole,tique},xeur},r{a{nche,sier,ve},ebis,èche,euvage,i{coler,gade,llant,oche,que},o{chure,der,nzer,usse,yeur},u{me,sque,tal,yant}},u{ffle,isson,lletin,r{eau,in},stier,t{iner,oir},v{able,ette}}} c{a{b{anon,ine},chette,d{eau,re},féine,i{llou,sson},l{culer,epin,ibre,mer,omnie,vaire},m{arade,éra,ion,pagne},n{al,eton,on,tine,ular},p{able,oral,rice,sule,ter,uche},r{abine,bone,esser,ibou,nage,otte,reau,ton},s{cade,ier,que,sure},u{ser,tion},v{alier,erne,iar}},édille,einture,éleste,e{llule,n{drier,surer,tral},rcle},érébral,e{r{ise,ner,veau},sser},h{a{grin,ise,leur,mbre,nce,pitre,rbon,sseur,ton,usson,virer},e{mise,nille},équier,e{rcher,val},i{en,ffre,gnon,mère,ot},lorure,o{colat,isir,se,uette},rome,ute},i{g{are,ogne},menter,n{éma,trer},r{culer,er,que},t{erne,oyen,ron},vil},l{a{iron,meur,quer,sse,vier},i{ent,gner,mat,vage},o{che,nage,porte}},o{b{alt,ra},c{asse,otier},d{er,ifier},ffre,gner,hésion,i{ffer,ncer},l{ère,ibri,line,mater,onel},m{bat,édie,mande,pact},n{cert,duire,fier,geler,noter,sonne,tact,vexe},p{ain,ie},r{ail,beau,dage,niche,pus,rect,tège},s{mique,tume},ton,u{de,pure,rage,teau,vrir},yote},r{a{be,inte,vate,yon},é{ature,diter,meux},e{user,vette},i{bler,er,stal,tère},o{ire,quer,tale},u{cial,el},ypter},u{bique,eillir,i{llère,sine,vre},l{miner,tiver},muler,pide,r{atif,seur}},y{anure,cle,lindre,nique}} d{a{igner,mier,n{ger,seur},uphin},é{b{attre,iter,order,rider,utant},c{aler,embre,hirer,ider,larer,orer,rire,upler},d{ale,uctif},esse,f{ensif,iler,rayer},g{ager,ivrer,lutir,rafer},jeuner,l{ice,oger}},em{ander,eurer},é{molir,n{icher,ouer}},entelle,é{nuder,p{art,enser,haser,lacer,oser},r{anger,ober},sastre},escente,és{ert,igner,obéir},es{siner,trier},ét{acher,ester,ourer,resse},ev{ancer,enir,iner,oir},i{a{ble,logue,mant},cter,fférer,g{érer,ital,ne},luer,m{anche,inuer},oxyde,r{ectif,iger},s{cuter,poser,siper,tance},v{ertir,iser}},o{c{ile,teur},gme,igt,m{aine,icile,pter},n{ateur,jon,ner},pamine,r{toir,ure},s{age,eur,sier},tation,u{anier,ble,ceur,ter},yen},r{a{gon,per},esser,ibbler,oiture},u{p{erie,lexe},r{able,cir}},ynastie} é{blouir,c{arter,h{arpe,elle},l{airer,ipse,ore,use},o{le,nomie,rce,uter},r{aser,émer,ivain,ou},u{me,reuil}},d{ifier,uquer}} eff{acer,ectif,igie,ort,rayer,usion} é{ga{liser,rer},jecter,l{a{borer,rgir},ectron,é{gant,phant},ève,i{gible,tisme},oge,u{cider,der}}} emb{aller,ellir,ryon} ém{eraude,ission} emmener émo{tion,uvoir} emp{ereur,loyer,orter,rise} émulsion en{c{adrer,hère,lave,oche},d{iguer,osser,roit,uire}} énergie en{f{ance,ermer,ouir},g{ager,in,lober}} énigme en{j{amber,eu},lever,n{emi,uyeux},r{ichir,obage},seigne,t{asser,endre,ier,ourer,raver}} énumérer en{v{ahir,iable,oyer},zyme} é{olien,p{a{issir,rgne,tant,ule},i{cerie,démie,er,logue,ne,sode,taphe},oque,r{euve,ouver},uisant},qu{erre,ipe},r{iger,osion}} erreur éruption es{calier,p{adon,èce,iègle,oir,rit},quiver,s{ayer,ence,ieu,orer},t{ime,omac,rade}} ét{a{gère,ler,nche,tique},e{indre,ndoir,rnel},h{anol,ique}} ethnie ét{irer,o{ffer,ile,nnant,urdir},r{ange,oit},ude} euphorie év{a{luer,sion},entail,i{dence,ter},o{lutif,quer}} ex{a{ct,gérer,ucer},c{eller,itant,lusif,use},écuter,e{mple,rcer},h{aler,orter},i{gence,ler,ster},otique,p{édier,lorer,oser,rimer},quis,t{ensif,raire},ulter} f{a{b{le,uleux},c{ette,ile,ture},iblir,laise,m{eux,ille},r{ceur,felu,ine,ouche},sciner,t{al,igue},u{con,tif},v{eur,ori}},é{brile,conder,dérer,lin},emme,émur,endoir,éodal,ermer,éroce,e{rveur,stival,u{ille,tre}},évrier,i{asco,c{eler,tif},dèle,gure,l{ature,etage,ière,leul,mer,ou,trer},n{ancer,ir},ole,rme,ssure,xer},l{a{irer,mme,sque,tteur},éau,èche,e{ur,xion},o{con,re},u{ctuer,ide,vial}},o{lie,n{derie,gible,taine},r{cer,geron,muler,tune},ssile,u{dre,gère,iller,lure,rmi}},r{a{gile,ise,nchir,pper,yeur},égate,e{iner,lon},é{mir,nésie},ère,i{able,ction,sson,vole},o{id,mage,ntal,tter},uit},u{gitif,ite,r{eur,ieux,tif},sion,tur}} g{a{gner,l{axie,erie},mbader,r{antir,dien,nir,rigue},z{elle,on}},é{ant,l{atine,ule}},endarme,én{éral,ie},en{ou,til},é{o{logie,mètre},ranium},e{rme,stuel,yser},i{bier,cler,rafe,vre},l{a{ce,ive},isser,o{be,ire,rieux}},o{lfeur,mme,nfler,r{ge,ille},u{dron,ffre,lot,pille,rmand,tte}},r{a{duel,ffiti,ine,nd,ppin,tuit,vir},enat,i{ffure,ller,mper},o{gner,nder,tte,upe},u{ger,tier,yère}},u{épard,errier,i{de,mauve,tare},statif},y{mnaste,rostat}} h{a{bitude,choir,lte,meau,n{gar,neton},r{icot,monie,pon},sard},é{lium,matome},erbe,érisson,ermine,é{ron,siter},eureux,i{b{erner,ou},larant,stoire,ver},o{m{ard,mage,ogène},n{neur,orer,teux},r{de,izon,loge,mone,rible},u{leux,sse}},u{blot,ileux,m{ain,ble,ide,our},rler},y{dromel,giène,mne,pnose}} i{dylle,g{norer,uane},ll{icite,usion},m{age,biber,iter,m{ense,obile,uable},p{act,érial,lorer,oser,rimer,uter}},n{c{arner,endie,ident,liner,olore},d{exer,ice,uctif},édit,e{ptie,xact},f{ini,liger,ormer,usion},gérer,h{aler,iber},j{ecter,ure},nocent,o{culer,nder},s{crire,ecte,igne,olite,pirer,tinct,ulter},t{act,ense,ime,rigue,uitif},utile,v{asion,enter,iter,oquer}},r{onique,r{adier,éel,iter}},soler,v{oire,resse}} j{a{guar,illir,mbe,nvier,rdin,u{ger,ne},velot},e{t{able,on},u{di,nesse}},o{indre,n{cher,gler},u{eur,issif,rnal},vial,y{au,eux}},u{biler,gement,nior,pon,riste,stice,teux,vénile}} k{ayak,i{mono,osque}} l{a{b{el,ial,ourer},c{érer,tose},gune,i{ne,sser,tier},m{beau,elle,pe},n{ceur,gage,terne},pin,r{geur,me},urier,v{abo,oir}},ecture,ég{al,er,ume},e{ssive,ttre,vier,xique},ézard,i{asse,b{érer,re},c{ence,orne},è{ge,vre},g{ature,oter,ue},m{er,ite,onade,pide},n{éaire,got},onceau,quide,s{ière,ter},t{hium,ige,toral},vreur},o{gique,i{ntain,sir},mbric,terie,u{er,rd,tre,ve},yal},u{bie,c{ide,ratif},eur,gubre,isant,mière,n{aire,di},ron,tter,xueux}} m{a{chine,g{asin,enta,ique},i{gre,llon,ntien,rie,son},jorer,l{axer,éfice,heur,ice,lette},mmouth,n{dater,iable,quant,teau,uel},r{athon,bre,chand,di,itime,queur,ron,teler},s{cotte,sif},t{ériel,ière,raque},u{dire,ssade,ve},ximal},é{c{hant,onnu},d{aille,ecin,iter,use}},eilleur,él{ange,odie},embre,émoire,e{n{acer,er,hir,songe,tor},rcredi},érite,e{rle,s{sager,ure}},ét{al,éore,hode,ier},euble,i{auler,crobe,ette,g{non,rer},l{ieu,lion},mique,n{ce,éral,imal,orer,ute},r{acle,oiter},ssile,xte},o{bile,derne,elleux,n{dial,iteur,naie,otone,stre,tagne,ument},queur,r{ceau,sure,tier},t{eur,if},u{che,fle,lin,sson,ton,vant}},u{ltiple,nition,r{aille,ène,mure},s{cle,éum,icien},t{ation,er,uel}},y{r{iade,tille},stère,thique}} n{a{geur,ppe,r{quois,rer},t{ation,ion,ure},u{frage,tique},vire},ébuleux,ectar,é{faste,g{ation,liger,ocier}},e{ige,rveux,ttoyer,u{rone,tron},veu},i{c{he,kel},trate,veau},o{ble,c{if,turne},i{rceur,sette},m{ade,breux,mer},rmatif,t{able,ifier,oire},u{rrir,veau},v{ateur,embre,ice}},u{a{ge,ncer},i{re,sible},méro,ptial,que,tritif}} o{b{éir,jectif,liger,s{cur,erver,tacle},t{enir,urer}},c{c{asion,uper},éan,t{obre,royer,upler},ulaire},d{eur,orant},ff{enser,icier,rir},give,is{eau,illon},l{factif,ivier},m{brage,ettre},n{ctueux,duler,éreux,irique},p{a{le,que},érer,inion,p{ortun,rimer},t{er,ique}},r{a{geux,nge},bite,donner,eille,g{ane,ueil},ifice,nement,que,tie},s{ciller,mose,sature},tarie,u{r{agan,son},t{il,rager},vrage},vation,xy{de,gène},zone} p{a{isible,l{ace,marès,ourde,per},n{ache,da,golin,iquer,neau,orama,talon},p{aye,ier,oter,yrus},r{adoxe,celle,esse,fumer,ler,ole,rain,semer,tager,ure,venir},s{sion,tèque},t{ernel,ience,ron},v{illon,oiser},y{er,sage}},e{i{gne,ntre},lage},élican,e{l{le,ouse,uche},ndule},én{étrer,ible},ensif,é{nurie,p{ite,lum}},er{drix,forer},ériode,e{r{muter,plexe,sil,te},ser},étale,etit,étrir,euple,h{araon,o{bie,que,ton},rase,ysique},i{ano,ctural,èce,e{rre,uvre},lote,nceau,pette,quer,rogue,s{cine,ton},voter,xel,zza},l{a{card,fond,isir,ner,que,stron,teau},e{urer,xus},iage,o{mb,nger},u{ie,mage}},o{chette,ésie,ète,i{nte,rier,sson,vre},l{aire,icier,len,ygone},m{made,pier},n{ctuel,dérer,ey},rtique,s{ition,séder,ture},t{ager,eau,ion},u{ce,lain,mon,rpre,ssin,voir}},r{a{irie,tique},é{cieux,dire,fixe,lude,nom,sence,texte,voir},i{mitif,nce,son,ver},o{blème,céder,dige,fond,grès,ie,jeter,logue,mener,pre,spère,téger,uesse,verbe},u{dence,neau}},sychose,u{blic,ceron,iser,l{pe,sar},n{aise,itif},pitre,rifier,zzle},yramide} qu{asar,e{relle,stion},i{étude,tter},otient} r{a{c{ine,onter},dieux,gondin,i{deur,sin},l{entir,longe},masser,pide,sage,tisser,v{ager,in},yonner},éa{ctif,gir,liser,nimer},ecevoir,éc{iter,lamer,olter},ec{ruter,uler,ycler},édiger,e{douter,faire},éf{lexe,ormer},ef{rain,uge},é{g{alien,ion,lage,ulier},itérer},e{j{eter,ouer},l{atif,ever,ief},m{arque,ède,ise,onter,plir,uer},n{ard,fort,ifler,oncer,trer,voi},p{lier,orter,rise,tile},quin},és{erve,ineux,oudre},es{pect,ter},é{sultat,tablir},etenir,éticule,et{omber,racer},éu{nion,ssir},ev{anche,ivre},év{olte,ulsif},i{chesse,deau,eur,g{ide,oler},ncer,poster,s{ible,que},tuel,v{al,ière}},o{cheux,m{ance,pre},n{ce,din},s{eau,ier},t{atif,or,ule},u{ge,ille,leau,tine},yaume},u{b{an,is},che,elle,gueux,i{ner,sseau},s{er,tique}},ythme} s{a{b{ler,oter,re},coche,fari,gesse,isir,l{ade,ive,on,uer},medi,n{ction,glier},r{casme,dine},turer,u{grenu,mon,ter,vage},v{ant,onner}},c{a{lpel,ndale},é{lérat,nario},eptre,héma,i{ence,nder},ore,rutin,ulpter},é{ance,c{able,her}},ecouer,é{créter,d{atif,uire}},eigneur,é{jour,lectif},em{aine,bler,ence},é{minal,nateur},en{sible,tence},é{parer,quence},er{ein,gent},érieux,errure,érum,ervice,é{same,vir},e{vrage,xtuple},i{déral,ècle,éger,ffler,g{le,nal},l{ence,icium},mple,n{cère,istre},phon,rop,smique,tuer},kier,o{c{ial,le},dium,igneux,l{dat,eil,itude,uble},m{bre,meil,noler},n{de,geur,nette,ore},r{cier,tir},sie,ttise,u{cieux,dure,ffle,lever,pape,rce,tirer,venir}},p{a{cieux,tial},écial,hère,iral},t{a{ble,tion},ernum,i{mulus,puler},rict,u{dieux,peur},yliste},u{b{lime,strat,til,venir},c{cès,re},ffixe,ggérer,iveur,lfate,p{erbe,plier},r{face,icate,mener,prise,saut,vie},spect},y{llabe,m{bole,étrie},n{apse,taxe},stème}} t{a{b{ac,lier},ctile,iller,l{ent,isman,onner},m{bour,iser},ngible,pis,quiner,r{der,if,tine},sse,t{ami,ouage},u{pe,reau},xer},émoin,e{mporel,n{aille,dre,eur,ir,sion},r{miner,ne,rible}},étine,exte,h{ème,é{orie,rapie},orax},i{bia,ède,mide,r{elire,oir},ssu,t{ane,re,uber}},o{boggan,lérant,mate,n{ique,neau},ponyme,r{che,dre,nade,pille,rent,se,tue},tem,u{cher,rnage,sser},xine},r{a{ction,fic,gique,hir,in,ncher,vail},èfle,emper,ésor,euil,i{age,bunal,coter,logie,omphe,pler,turer,vial},o{mbone,nc,pical,upeau}},u{ile,lipe,multe,nnel,rbine,t{eur,oyer},yau},y{mpan,p{hon,ique},ran}} u{buesque,lt{ime,rason},n{anime,i{fier,on,que,taire,vers}},r{anium,bain,ticant},s{age,ine,u{el,re}},t{ile,opie}} v{a{c{arme,cin},g{abond,ue},i{llant,ncre,sseau},l{able,ise,lon,ve},mpire,nille,peur,rier,s{eux,sal,te}},e{cteur,dette},é{gétal,hicule},einard,éloce,endredi,énérer,e{n{ger,imeux,touse},rdure},érin,e{r{nir,rou,ser,tu},ston},ét{éran,uste},ex{ant,er},i{a{duc,nde},ctoire,d{ange,éo},g{nette,ueur},l{ain,lage},naigre,olon,père,r{ement,tuose,us},s{age,eur,ion,queux,uel},t{al,esse,icole,rine},v{ace,ipare}},o{cation,guer,i{le,sin,ture},l{aille,can,tiger,ume},r{ace,tex},ter,uloir,y{age,elle}}} wagon xénon yacht z{èbre,énith,este,oologie} ;;
    es?(_*)) echo ábaco a{b{domen,eja,ierto,o{gado,no,rto},r{azo,ir},u{elo,so}},c{a{bar,demia},c{eso,ión},e{ite,lga,nto,ptar}}} ácido a{c{larar,né,o{ger,so},t{ivo,o,riz,uar},u{dir,erdo,sar}},d{icto,mitir,o{ptar,rno},u{ana,lto}},éreo,f{ectar,i{ción,nar,rmar}}} ágil ag{itar,o{nía,sto,tar},r{egar,io},u{a,do}} águila a{guja,ho{go,rro},i{re,slar},j{e{drez,no},uste},l{a{crán,mbre,rma},ba}} álbum a{l{calde,dea,e{gre,jar,rta,ta},filer,g{a,odón},i{ado,ento,vio},m{a,eja,íbar},t{ar,eza,ivo,o,ura},umno,zar},ma{ble,nte,pola,rgo,sar}} ámb{ar,ito} a{m{eno,i{go,stad},or,p{aro,lio}},n{c{ho,iano,la},d{ar,én},emia}} ángulo anillo ánimo a{n{ís,otar,t{ena,iguo,ojo},u{al,lar,ncio}},ñ{adir,ejo,o},p{a{gar,rato},etito,io,licar,o{do,rte,yo},r{ender,obar},u{esta,ro}},ra{do,ña,r}} árb{itro,ol} ar{busto,c{hivo,o},d{er,illa,uo}} ár{ea,ido} a{r{ies,monía,nés,oma,p{a,ón},r{eglo,oz,uga},t{e,ista}},s{a{,do,lto},censo,e{gurar,o,sor},i{ento,lo,stir},no,ombro}} áspero a{s{t{illa,ro,uto},u{mir,nto}},t{a{jo,que,r},e{nto,o}}} ático atleta átomo a{t{r{aer,oz},ún},u{d{az,io},ge,la,mento,sente,tor},v{a{l,nce,ro},e{,llana,na,struz},i{ón,so}},y{er,u{da,no}},z{a{frán,r},ote,úcar,u{fre,l}}} b{a{b{a,or},che,hía,ile,jar,l{anza,cón,de},mbú,n{co,da},ño,r{ba,co,niz,ro}},áscula,a{s{tón,ura},t{alla,ería,ir,uta},úl,zar},e{b{é,ida},llo,s{ar,o,tia}},i{cho,en,ngo},l{anco,oque,usa},o{a,b{ina,o},c{a,ina},d{a,ega},ina,l{a,ero,sa},mba,n{dad,ito,o,sái},r{de,rar},sque,t{e,ín}},óveda,ozal,r{a{vo,zo},e{cha,ve},i{llo,nco,sa},o{ca,ma,nce,te},u{ja,sco,to}},u{c{eo,le},e{no,y},f{anda,ón}},úho,u{itre,lto,r{buja,la,ro},scar,taca,zón}} c{a{b{allo,eza,ina,ra},cao,d{áver,ena},er,fé,ída,imán,j{a,ón},l{,amar,cio,do,idad,le,ma,or,vo},m{a,bio,ello,ino,po}},áncer,a{n{dil,ela,guro,ica,to},ñ{a,ón},o{ba,s},p{az,itán,ote,tar,ucha},r{a,bón}},árcel,a{r{eta,ga,iño,ne,peta,ro,ta},s{a,co,ero,pa,tor},t{orce,re},u{dal,sa},zo},e{bolla,d{er,ro},lda},élebre,eloso,élula,e{mento,n{iza,tro},r{ca,do,eza,o,rar,teza}},ésped,etro,h{a{cal,leco,mpú,ncla,pa,rla},i{co,ste,vo},o{que,za},u{leta,par}},i{clón,e{go,lo,n,rto},fra,garro,ma,n{co,e,ta},prés,r{co,uela},sne,ta,udad},l{a{mor,n,ro,se,ve},i{ente,ma},ínica},o{bre,c{ción,hino,ina,o}},ódigo,o{do,fre,ger,hete,j{ín,o},l{a,cha,egio,gar,ina,lar,mo,umna},m{bate,er,ida}},ómodo,o{mpra,n{de,ejo,ga,ocer,sejo,tar},p{a,ia},r{azón,bata,cho,dón,ona,rer},s{er,mos,ta}},r{á{neo,ter},e{ar,cer,ído,ma},ía,i{men,pta,sis},omo,ónica,oqueta,u{do,z}},u{a{dro,rto,tro},b{o,rir},chara,e{llo,nto,rda,sta,va},idar,l{ebra,pa,to},m{bre,plir},n{a,eta},ota,pón},úpula,u{r{ar,ioso,so,va},tis}} d{a{ma,nza,r{,do}},átil,eber,é{bil,cada},e{cir,do,f{ensa,inir},jar,l{fín,gado,ito},mora,n{so,tal},porte,r{echo,rota},s{ayuno,eo,file,nudo,tino,vío},t{alle,ener},uda},ía,i{a{blo,dema,mante,na,rio},bujo,ctar,e{nte,ta,z},fícil,gno,l{ema,uir},nero,r{ecto,igir},s{co,eño,fraz},v{a,ino}},o{ble,ce,lor,mingo,n{,ar},r{ado,mir,so},s{,is}},r{agón,oga},u{cha,da,e{lo,ño},lce},úo,u{que,r{ar,eza,o}}} ébano e{brio,c{har,o,uador},d{ad,i{ción,ficio,tor},ucar},f{ecto,icaz},je{,mplo},l{e{fante,gir,mento,var},ipse}} élite e{l{ixir,ogio,udir},m{budo,itir,oción,p{ate,eño,leo,resa}},n{ano,c{argo,hufe,ía},e{migo,ro},f{ado,ermo},gaño,igma,lace,orme,redo,s{ayo,eñar},t{ero,rar},v{ase,ío}}} época e{quipo,rizo,s{c{ala,ena,olar,ribir,udo},encia,f{era,uerzo},p{ada,ejo,ía,osa,uma},quí,t{ar,e,ilo,ufa}},t{apa,erno}} ética e{tnia,v{a{dir,luar},ento,itar},x{a{cto,men},c{eso,usa},ento,i{gir,lio,stir}}} éxito ex{p{erto,licar,oner},tremo} f{áb{rica,ula},achada,ácil,a{ctor,ena,ja,l{da,lo,so,tar},m{a,ilia,oso},r{aón,macia,ol,sa},se,tiga,una,vor,x},e{brero,cha,liz,o,r{ia,oz}},értil,e{rvor,stín},i{a{ble,nza,r},bra,c{ción,ha},deo,e{bre,l,ra,sta},gura,j{ar,o},l{a,ete,ial,tro},n{,ca,gir,ito},rma},l{a{co,uta},echa,o{r,ta},u{ir,jo},úor},o{bia,ca,g{ata,ón},l{io,leto},ndo,r{ma,ro,tuna,zar},sa,to},r{acaso,ágil,a{nja,se,ude},e{ír,no,sa},ío,ito,uta},u{e{go,nte,rza},ga,mar,n{ción,da},r{gón,ia},sil},útbol,uturo} g{a{cela,fas,ita,jo,l{a,ería,lo},mba,n{ar,cho,ga,so},r{aje,za},s{olina,tar},to,vilán},e{m{elo,ir},n},énero,e{n{io,te},r{anio,ente,men},sto},i{gante,mnasio,r{ar,o}},l{aciar,o{bo,ria}},o{l{,fo,oso,pe},ma,r{do,ila,ra},t{a,eo},zar},r{ada,áfico,a{no,sa,tis,ve},i{eta,llo,pe,s,to},osor,úa,u{eso,mo,po}},u{a{nte,po,rdia},erra,ía,i{ño,on,so,tarra},s{ano,tar}}} h{aber,ábil,a{blar,c{er,ha},da,llar,maca,rina,z{,aña}},e{b{illa,ra},cho,l{ado,io},mbra,r{ir,mano}},éroe,ervir,ie{lo,rro},ígado,i{giene,jo,mno,storia},o{cico,g{ar,uera},ja,mbre,n{go,or,ra},r{a,miga,no},stil,yo},u{e{co,lga,rta,so,vo},i{da,r},mano},úmedo,u{m{ilde,o},ndir,r{acán,to}}} i{cono,d{eal,ioma}} ídolo i{g{l{esia,ú},ual},l{egal,usión},m{agen,án,itar,p{ar,erio,oner,ulso}},ncapaz} índice in{erte,f{iel,orme},genio,icio,m{enso,une},nato,s{ecto,tante},terés} íntimo i{n{tuir,útil,vierno},r{a,is,onía},sl{a,ote}} j{a{b{alí,ón},món,r{abe,dín,ra},ula,zmín},e{fe,ringa},inete,o{r{nada,oba},ven,ya},u{e{rga,ves,z},g{ador,o,uete},icio,n{co,gla,io,tar}},úpiter,u{rar,sto,venil,zgar}} k{ilo,oala} l{a{bio,c{io,ra},d{o,rón},garto},ágrima,a{guna,ico,mer},ám{ina,para},an{a,cha,gosta,za},ápiz,ar{go,va},ástima,ata,átex,a{tir,urel,var,zo},e{al,c{ción,he,tor},er,g{ión,umbre},jano,n{gua,to},ña,ón,opardo,sión,t{al,ra},ve,yenda},i{b{ertad,ro},cor},íder,i{diar,enzo,g{a,ero},ma},ímite,i{m{ón,pio},n{ce,do}},ínea,in{gote,o,terna},íquido,i{s{o,ta},t{era,io,ro}},l{a{ga,ma,nto,ve},e{gar,nar,var},o{rar,ver},uvia},o{bo,c{ión,o,ura}},ógica,o{gro,m{briz,o},nja,te},u{c{ha,ir},gar,jo,n{a,es},pa,stro,to,z}} m{a{c{eta,ho},d{era,re,uro},estro,fia,g{ia,o},íz,l{dad,eta,la,o},m{á,bo,ut},n{co,do,ejar,ga,iquí,jar,o,so,ta},ñana,pa},áquina,ar{,co,ea,fil,gen,ido},ármol,a{r{rón,tes,zo},sa},áscara,a{sivo,t{ar,eria,iz,riz}},áximo,a{yor,zorca},e{cha,d{alla,io}},édula,e{j{illa,or},l{ena,ón},moria,n{or,saje,te,ú},r{cado,engue}},érito,e{s{,ón},t{a,er}},étodo,e{tro,zcla},i{e{do,l,mbro},ga,l{,agro,itar,lón},mo,n{a,ero}},ínimo,i{nuto,ope,rar,s{a,eria,il,mo},t{ad,o}},o{c{hila,ión},d{a,elo},ho,jar,l{de,er,ino},m{ento,ia},n{arca,eda,ja,to},ño,r{ada,der,eno,ir,ro,sa,tal},s{ca,trar},tivo,ver},óvil,ozo,u{cho,dar,e{ble,la,rte,stra},gre,jer,l{a,eta,ta},ndo,ñeca,r{al,o}},úsculo,us{eo,go},úsica,uslo} n{ácar,a{ción,dar,ipe,r{anja,iz,rar},sal,t{al,ivo,ural}},áusea,av{al,e,idad},ecio,éctar,e{g{ar,ocio,ro},ón,rvio,to,utro,v{ar,era}},i{cho,do,e{bla,to},ñ{ez,o}},ítido,ivel,o{bleza,che},ómina,o{r{ia,ma,te},t{a,icia},v{ato,ela,io}},u{be,ca},úcleo,u{d{illo,o},e{ra,ve,z},lo},úmero,utria} o{asis,b{eso,ispo,jeto,r{a,ero},servar,tener,vio},c{a{,so},éano,h{enta,o},io,re,t{avo,ubre},u{lto,par,rrir}},di{ar,o,sea},este,f{e{nsa,rta},icio,recer},gro,í{do,r},jo,l{a,eada,fato,ivo,la,mo,or,vido},mbligo,n{da,za},p{aco,ción}} ópera op{inar,oner,tar} óptica o{puesto,ra{ción,dor,l}} órbita or{ca,den,eja} órgano o{r{g{ía,ullo},i{ente,gen,lla},o,questa,uga},s{adía,curo,ezno,o,tra},t{oño,ro},veja} ó{vulo,xido} o{xígeno,yente,zono} p{a{cto,dre,ella},ágina,a{go,ís},ájaro,al{abra,co,eta},álido,a{l{ma,oma,par},n{,al}},ánico,a{ntera,ñuelo,p{á,el,illa},quete,r{ar,cela,ed,ir,o}},árpado,arque,árrafo,a{rte,s{ar,eo,ión,o,ta},t{a,io,ria},u{sa,ta},vo,yaso},e{atón,c{ado,era,ho},d{al,ir},gar,ine,l{ar,daño,ea,igro,lejo,o,uca},n{a,sar},ñón,ón,or,pino,queño,r{a,cha,der,eza,fil,ico,la,miso,ro,sona},s{a,ca}},ésimo,estaña,étalo,e{tróleo,z{,uña}},i{c{ar,hón},e{,dra,rna,za},jama,l{ar,oto},mienta,n{o,tor,za},ña,ojo,pa,rata,s{ar,cina,o,ta},tón,zca},l{a{ca,n,ta,ya,za},e{ito,no},omo,u{ma,ral}},o{bre,co,d{er,io},e{ma,sía,ta},l{en,icía,lo,vo},m{ada,elo,o,pa},ner,r{ción,tal},s{ada,eer,ible,te},t{encia,ro},zo},r{ado,e{coz,gunta,mio,nsa,so,vio},imo,íncipe,i{sión,var},o{a,bar,ceso,ducto,eza,fesor,grama,le,mesa,nto,pio},óximo,ueba},úblico,u{chero,dor,e{blo,rta,sto},l{ga,ir,món,po,so},ma,nto,ñ{al,o},p{a,ila},ré}} qu{e{dar,ja,mar,rer,so},ieto,ímica,i{nce,tar}} r{ábano,a{b{ia,o},ción,dical,íz,m{a,pa},n{cho,go},paz},ápido,a{pto,s{go,pa},to,yo,z{a,ón}},e{a{cción,lidad},b{año,ote},c{aer,eta,hazo,oger,reo,to,urso},d{,ondo,ucir},f{lejo,orma,rán,ugio},g{alo,ir,la,reso},hén,ino,ír,ja,l{ato,evo,ieve,leno,oj},m{ar,edio,o},n{cor,dir,ta},p{arto,etir,oso,til},s{,cate,ina,peto,to,umen},t{iro,orno,rato},unir,v{és,ista},y,zar},i{co,e{go,nda,sgo},fa},ígido,i{gor,ncón,ñón},ío,i{queza,sa,t{mo,o},zo},o{ble,c{e,iar},d{ar,eo,illa},er,j{izo,o},m{ero,per},n{,co,da},p{a,ero},s{a,ca,tro},tar},u{b{í,or},do,eda,gir,i{do,na},l{eta,o},m{bo,or},ptura,t{a,ina}}} s{ábado,a{b{er,io,le},car,g{az,rado},l{a,do,ero,ir,món,ón,sa,to,ud,var},mba,n{ción,día,ear,gre,idad,o,to},po,que,r{dina,tén},stre,tán,una,xofón},e{c{ción,o,reto,ta},d,guir,is,l{lo,va},m{ana,illa},n{da,sor},ñ{al,or},p{arar,ia},quía,r{,ie,món,vir},s{enta,ión},t{a,enta},vero,x{o,to}},i{dra,e{sta,te},g{lo,no}},ílaba,il{bar,encio,la},ímbolo,i{mio,rena,stema,t{io,uar}},o{bre,cio,dio,l{,apa,dado,edad}},ólido,o{l{tar,ución},mbra,n{deo,ido,oro,risa},p{a,lar,orte},r{do,presa,teo},stén},ótano,u{ave,bir,ceso,dor,e{gra,lo,ño,rte},frir,jeto,ltán,mar,p{erar,lir,oner,remo},r{,co,eño,gir},sto,til}} t{a{b{aco,ique,la,ú},c{o,to},jo,l{ar,co,ento,la,ón},m{año,bor},n{go,que},p{a,ete,ia,ón},quilla,r{de,ea,ifa,jeta,ot,ro,ta},tuaje,uro,z{a,ón}},e{atro,c{ho,la}},écnica,e{j{ado,er,ido},l{a,éfono},m{a,or,plo},n{az,der,er,is,so},oría,r{apia,co}},érmino,e{r{nura,ror},s{is,oro,tigo},tera,xto,z},i{b{io,urón},e{mpo,nda,rra,so},gre,jera,lde,mbre},ímido,i{mo,nta},í{o,pico},i{po,r{a,ón},tán},ít{ere,ulo},iza,o{alla,billo,c{ar,ino},do,ga,ldo,mar,n{o,to},p{ar,e},que},órax,o{r{ero,menta,neo,o,pedo,re,so,tuga},s{,co,er}},óxico,r{a{bajo,ctor,er},áfico,a{go,je,mo,nce,to,uma,zar},ébol,e{gua,inta,n,par,s},i{bu,go,pa,ste,unfo},o{feo,mpa,nco,pa,te,zo},u{co,eno,fa}},u{b{ería,o},erto,m{ba,or}},ún{el,ica},u{r{bina,ismo,no},tor}} ubicar úlcera u{mbral,n{i{dad,r,verso},o,tar},ña,r{b{ano,e},gente,na},s{ar,uario}} útil u{topía,va} v{a{c{a,ío,una},g{ar,o},ina,jilla,le},álido,al{le,or},álvula,a{mpiro,r{a,iar,ón},so},e{c{ino,tor},hículo,inte,jez,l{a,ero,oz},n{a,cer,da,eno,gar,ir,ta,us},r{,ano,bo,de,eda,ja,so,ter}},ía,i{aje,brar,cio},íctima,ida,ídeo,i{drio,e{jo,rnes},gor,l{,la},n{agre,o},ñedo,olín,r{al,go,tud},sor},íspera,i{sta,tamina,udo,v{az,ero,ir,o}},o{l{cán,umen,ver},raz,t{ar,o},z},u{elo,lgar}} y{a{cer,te},e{gua,ma,rno,so},o{do,g{a,ur}}} z{a{firo,nja,pato,rza},o{na,rro},u{mo,rdo}} ;;
    zh_CN)   echo 的 一 是 在 不 了 有 和 人 这 中 大 为 上 个 国 我 以 要 他 时 来 用 们 生 到 作 地 于 出 就 分 对 成 会 可 主 发 年 动 同 工 也 能 下 过 子 说 产 种 面 而 方 后 多 定 行 学 法 所 民 得 经 十 三 之 进 着 等 部 度 家 电 力 里 如 水 化 高 自 二 理 起 小 物 现 实 加 量 都 两 体 制 机 当 使 点 从 业 本 去 把 性 好 应 开 它 合 还 因 由 其 些 然 前 外 天 政 四 日 那 社 义 事 平 形 相 全 表 间 样 与 关 各 重 新 线 内 数 正 心 反 你 明 看 原 又 么 利 比 或 但 质 气 第 向 道 命 此 变 条 只 没 结 解 问 意 建 月 公 无 系 军 很 情 者 最 立 代 想 已 通 并 提 直 题 党 程 展 五 果 料 象 员 革 位 入 常 文 总 次 品 式 活 设 及 管 特 件 长 求 老 头 基 资 边 流 路 级 少 图 山 统 接 知 较 将 组 见 计 别 她 手 角 期 根 论 运 农 指 几 九 区 强 放 决 西 被 干 做 必 战 先 回 则 任 取 据 处 队 南 给 色 光 门 即 保 治 北 造 百 规 热 领 七 海 口 东 导 器 压 志 世 金 增 争 济 阶 油 思 术 极 交 受 联 什 认 六 共 权 收 证 改 清 美 再 采 转 更 单 风 切 打 白 教 速 花 带 安 场 身 车 例 真 务 具 万 每 目 至 达 走 积 示 议 声 报 斗 完 类 八 离 华 名 确 才 科 张 信 马 节 话 米 整 空 元 况 今 集 温 传 土 许 步 群 广 石 记 需 段 研 界 拉 林 律 叫 且 究 观 越 织 装 影 算 低 持 音 众 书 布 复 容 儿 须 际 商 非 验 连 断 深 难 近 矿 千 周 委 素 技 备 半 办 青 省 列 习 响 约 支 般 史 感 劳 便 团 往 酸 历 市 克 何 除 消 构 府 称 太 准 精 值 号 率 族 维 划 选 标 写 存 候 毛 亲 快 效 斯 院 查 江 型 眼 王 按 格 养 易 置 派 层 片 始 却 专 状 育 厂 京 识 适 属 圆 包 火 住 调 满 县 局 照 参 红 细 引 听 该 铁 价 严 首 底 液 官 德 随 病 苏 失 尔 死 讲 配 女 黄 推 显 谈 罪 神 艺 呢 席 含 企 望 密 批 营 项 防 举 球 英 氧 势 告 李 台 落 木 帮 轮 破 亚 师 围 注 远 字 材 排 供 河 态 封 另 施 减 树 溶 怎 止 案 言 士 均 武 固 叶 鱼 波 视 仅 费 紧 爱 左 章 早 朝 害 续 轻 服 试 食 充 兵 源 判 护 司 足 某 练 差 致 板 田 降 黑 犯 负 击 范 继 兴 似 余 坚 曲 输 修 故 城 夫 够 送 笔 船 占 右 财 吃 富 春 职 觉 汉 画 功 巴 跟 虽 杂 飞 检 吸 助 升 阳 互 初 创 抗 考 投 坏 策 古 径 换 未 跑 留 钢 曾 端 责 站 简 述 钱 副 尽 帝 射 草 冲 承 独 令 限 阿 宣 环 双 请 超 微 让 控 州 良 轴 找 否 纪 益 依 优 顶 础 载 倒 房 突 坐 粉 敌 略 客 袁 冷 胜 绝 析 块 剂 测 丝 协 诉 念 陈 仍 罗 盐 友 洋 错 苦 夜 刑 移 频 逐 靠 混 母 短 皮 终 聚 汽 村 云 哪 既 距 卫 停 烈 央 察 烧 迅 境 若 印 洲 刻 括 激 孔 搞 甚 室 待 核 校 散 侵 吧 甲 游 久 菜 味 旧 模 湖 货 损 预 阻 毫 普 稳 乙 妈 植 息 扩 银 语 挥 酒 守 拿 序 纸 医 缺 雨 吗 针 刘 啊 急 唱 误 训 愿 审 附 获 茶 鲜 粮 斤 孩 脱 硫 肥 善 龙 演 父 渐 血 欢 械 掌 歌 沙 刚 攻 谓 盾 讨 晚 粒 乱 燃 矛 乎 杀 药 宁 鲁 贵 钟 煤 读 班 伯 香 介 迫 句 丰 培 握 兰 担 弦 蛋 沉 假 穿 执 答 乐 谁 顺 烟 缩 征 脸 喜 松 脚 困 异 免 背 星 福 买 染 井 概 慢 怕 磁 倍 祖 皇 促 静 补 评 翻 肉 践 尼 衣 宽 扬 棉 希 伤 操 垂 秋 宜 氢 套 督 振 架 亮 末 宪 庆 编 牛 触 映 雷 销 诗 座 居 抓 裂 胞 呼 娘 景 威 绿 晶 厚 盟 衡 鸡 孙 延 危 胶 屋 乡 临 陆 顾 掉 呀 灯 岁 措 束 耐 剧 玉 赵 跳 哥 季 课 凯 胡 额 款 绍 卷 齐 伟 蒸 殖 永 宗 苗 川 炉 岩 弱 零 杨 奏 沿 露 杆 探 滑 镇 饭 浓 航 怀 赶 库 夺 伊 灵 税 途 灭 赛 归 召 鼓 播 盘 裁 险 康 唯 录 菌 纯 借 糖 盖 横 符 私 努 堂 域 枪 润 幅 哈 竟 熟 虫 泽 脑 壤 碳 欧 遍 侧 寨 敢 彻 虑 斜 薄 庭 纳 弹 饲 伸 折 麦 湿 暗 荷 瓦 塞 床 筑 恶 户 访 塔 奇 透 梁 刀 旋 迹 卡 氯 遇 份 毒 泥 退 洗 摆 灰 彩 卖 耗 夏 择 忙 铜 献 硬 予 繁 圈 雪 函 亦 抽 篇 阵 阴 丁 尺 追 堆 雄 迎 泛 爸 楼 避 谋 吨 野 猪 旗 累 偏 典 馆 索 秦 脂 潮 爷 豆 忽 托 惊 塑 遗 愈 朱 替 纤 粗 倾 尚 痛 楚 谢 奋 购 磨 君 池 旁 碎 骨 监 捕 弟 暴 割 贯 殊 释 词 亡 壁 顿 宝 午 尘 闻 揭 炮 残 冬 桥 妇 警 综 招 吴 付 浮 遭 徐 您 摇 谷 赞 箱 隔 订 男 吹 园 纷 唐 败 宋 玻 巨 耕 坦 荣 闭 湾 键 凡 驻 锅 救 恩 剥 凝 碱 齿 截 炼 麻 纺 禁 废 盛 版 缓 净 睛 昌 婚 涉 筒 嘴 插 岸 朗 庄 街 藏 姑 贸 腐 奴 啦 惯 乘 伙 恢 匀 纱 扎 辩 耳 彪 臣 亿 璃 抵 脉 秀 萨 俄 网 舞 店 喷 纵 寸 汗 挂 洪 贺 闪 柬 爆 烯 津 稻 墙 软 勇 像 滚 厘 蒙 芳 肯 坡 柱 荡 腿 仪 旅 尾 轧 冰 贡 登 黎 削 钻 勒 逃 障 氨 郭 峰 币 港 伏 轨 亩 毕 擦 莫 刺 浪 秘 援 株 健 售 股 岛 甘 泡 睡 童 铸 汤 阀 休 汇 舍 牧 绕 炸 哲 磷 绩 朋 淡 尖 启 陷 柴 呈 徒 颜 泪 稍 忘 泵 蓝 拖 洞 授 镜 辛 壮 锋 贫 虚 弯 摩 泰 幼 廷 尊 窗 纲 弄 隶 疑 氏 宫 姐 震 瑞 怪 尤 琴 循 描 膜 违 夹 腰 缘 珠 穷 森 枝 竹 沟 催 绳 忆 邦 剩 幸 浆 栏 拥 牙 贮 礼 滤 钠 纹 罢 拍 咱 喊 袖 埃 勤 罚 焦 潜 伍 墨 欲 缝 姓 刊 饱 仿 奖 铝 鬼 丽 跨 默 挖 链 扫 喝 袋 炭 污 幕 诸 弧 励 梅 奶 洁 灾 舟 鉴 苯 讼 抱 毁 懂 寒 智 埔 寄 届 跃 渡 挑 丹 艰 贝 碰 拔 爹 戴 码 梦 芽 熔 赤 渔 哭 敬 颗 奔 铅 仲 虎 稀 妹 乏 珍 申 桌 遵 允 隆 螺 仓 魏 锐 晓 氮 兼 隐 碍 赫 拨 忠 肃 缸 牵 抢 博 巧 壳 兄 杜 讯 诚 碧 祥 柯 页 巡 矩 悲 灌 龄 伦 票 寻 桂 铺 圣 恐 恰 郑 趣 抬 荒 腾 贴 柔 滴 猛 阔 辆 妻 填 撤 储 签 闹 扰 紫 砂 递 戏 吊 陶 伐 喂 疗 瓶 婆 抚 臂 摸 忍 虾 蜡 邻 胸 巩 挤 偶 弃 槽 劲 乳 邓 吉 仁 烂 砖 租 乌 舰 伴 瓜 浅 丙 暂 燥 橡 柳 迷 暖 牌 秧 胆 详 簧 踏 瓷 谱 呆 宾 糊 洛 辉 愤 竞 隙 怒 粘 乃 绪 肩 籍 敏 涂 熙 皆 侦 悬 掘 享 纠 醒 狂 锁 淀 恨 牲 霸 爬 赏 逆 玩 陵 祝 秒 浙 貌 役 彼 悉 鸭 趋 凤 晨 畜 辈 秩 卵 署 梯 炎 滩 棋 驱 筛 峡 冒 啥 寿 译 浸 泉 帽 迟 硅 疆 贷 漏 稿 冠 嫩 胁 芯 牢 叛 蚀 奥 鸣 岭 羊 凭 串 塘 绘 酵 融 盆 锡 庙 筹 冻 辅 摄 袭 筋 拒 僚 旱 钾 鸟 漆 沈 眉 疏 添 棒 穗 硝 韩 逼 扭 侨 凉 挺 碗 栽 炒 杯 患 馏 劝 豪 辽 勃 鸿 旦 吏 拜 狗 埋 辊 掩 饮 搬 骂 辞 勾 扣 估 蒋 绒 雾 丈 朵 姆 拟 宇 辑 陕 雕 偿 蓄 崇 剪 倡 厅 咬 驶 薯 刷 斥 番 赋 奉 佛 浇 漫 曼 扇 钙 桃 扶 仔 返 俗 亏 腔 鞋 棱 覆 框 悄 叔 撞 骗 勘 旺 沸 孤 吐 孟 渠 屈 疾 妙 惜 仰 狠 胀 谐 抛 霉 桑 岗 嘛 衰 盗 渗 脏 赖 涌 甜 曹 阅 肌 哩 厉 烃 纬 毅 昨 伪 症 煮 叹 钉 搭 茎 笼 酷 偷 弓 锥 恒 杰 坑 鼻 翼 纶 叙 狱 逮 罐 络 棚 抑 膨 蔬 寺 骤 穆 冶 枯 册 尸 凸 绅 坯 牺 焰 轰 欣 晋 瘦 御 锭 锦 丧 旬 锻 垄 搜 扑 邀 亭 酯 迈 舒 脆 酶 闲 忧 酚 顽 羽 涨 卸 仗 陪 辟 惩 杭 姚 肚 捉 飘 漂 昆 欺 吾 郎 烷 汁 呵 饰 萧 雅 邮 迁 燕 撒 姻 赴 宴 烦 债 帐 斑 铃 旨 醇 董 饼 雏 姿 拌 傅 腹 妥 揉 贤 拆 歪 葡 胺 丢 浩 徽 昂 垫 挡 览 贪 慰 缴 汪 慌 冯 诺 姜 谊 凶 劣 诬 耀 昏 躺 盈 骑 乔 溪 丛 卢 抹 闷 咨 刮 驾 缆 悟 摘 铒 掷 颇 幻 柄 惠 惨 佳 仇 腊 窝 涤 剑 瞧 堡 泼 葱 罩 霍 捞 胎 苍 滨 俩 捅 湘 砍 霞 邵 萄 疯 淮 遂 熊 粪 烘 宿 档 戈 驳 嫂 裕 徙 箭 捐 肠 撑 晒 辨 殿 莲 摊 搅 酱 屏 疫 哀 蔡 堵 沫 皱 畅 叠 阁 莱 敲 辖 钩 痕 坝 巷 饿 祸 丘 玄 溜 曰 逻 彭 尝 卿 妨 艇 吞 韦 怨 矮 歇 ;;
    zh_TW)   echo 的 一 是 在 不 了 有 和 人 這 中 大 為 上 個 國 我 以 要 他 時 來 用 們 生 到 作 地 於 出 就 分 對 成 會 可 主 發 年 動 同 工 也 能 下 過 子 說 產 種 面 而 方 後 多 定 行 學 法 所 民 得 經 十 三 之 進 著 等 部 度 家 電 力 裡 如 水 化 高 自 二 理 起 小 物 現 實 加 量 都 兩 體 制 機 當 使 點 從 業 本 去 把 性 好 應 開 它 合 還 因 由 其 些 然 前 外 天 政 四 日 那 社 義 事 平 形 相 全 表 間 樣 與 關 各 重 新 線 內 數 正 心 反 你 明 看 原 又 麼 利 比 或 但 質 氣 第 向 道 命 此 變 條 只 沒 結 解 問 意 建 月 公 無 系 軍 很 情 者 最 立 代 想 已 通 並 提 直 題 黨 程 展 五 果 料 象 員 革 位 入 常 文 總 次 品 式 活 設 及 管 特 件 長 求 老 頭 基 資 邊 流 路 級 少 圖 山 統 接 知 較 將 組 見 計 別 她 手 角 期 根 論 運 農 指 幾 九 區 強 放 決 西 被 幹 做 必 戰 先 回 則 任 取 據 處 隊 南 給 色 光 門 即 保 治 北 造 百 規 熱 領 七 海 口 東 導 器 壓 志 世 金 增 爭 濟 階 油 思 術 極 交 受 聯 什 認 六 共 權 收 證 改 清 美 再 採 轉 更 單 風 切 打 白 教 速 花 帶 安 場 身 車 例 真 務 具 萬 每 目 至 達 走 積 示 議 聲 報 鬥 完 類 八 離 華 名 確 才 科 張 信 馬 節 話 米 整 空 元 況 今 集 溫 傳 土 許 步 群 廣 石 記 需 段 研 界 拉 林 律 叫 且 究 觀 越 織 裝 影 算 低 持 音 眾 書 布 复 容 兒 須 際 商 非 驗 連 斷 深 難 近 礦 千 週 委 素 技 備 半 辦 青 省 列 習 響 約 支 般 史 感 勞 便 團 往 酸 歷 市 克 何 除 消 構 府 稱 太 準 精 值 號 率 族 維 劃 選 標 寫 存 候 毛 親 快 效 斯 院 查 江 型 眼 王 按 格 養 易 置 派 層 片 始 卻 專 狀 育 廠 京 識 適 屬 圓 包 火 住 調 滿 縣 局 照 參 紅 細 引 聽 該 鐵 價 嚴 首 底 液 官 德 隨 病 蘇 失 爾 死 講 配 女 黃 推 顯 談 罪 神 藝 呢 席 含 企 望 密 批 營 項 防 舉 球 英 氧 勢 告 李 台 落 木 幫 輪 破 亞 師 圍 注 遠 字 材 排 供 河 態 封 另 施 減 樹 溶 怎 止 案 言 士 均 武 固 葉 魚 波 視 僅 費 緊 愛 左 章 早 朝 害 續 輕 服 試 食 充 兵 源 判 護 司 足 某 練 差 致 板 田 降 黑 犯 負 擊 范 繼 興 似 餘 堅 曲 輸 修 故 城 夫 夠 送 筆 船 佔 右 財 吃 富 春 職 覺 漢 畫 功 巴 跟 雖 雜 飛 檢 吸 助 昇 陽 互 初 創 抗 考 投 壞 策 古 徑 換 未 跑 留 鋼 曾 端 責 站 簡 述 錢 副 盡 帝 射 草 衝 承 獨 令 限 阿 宣 環 雙 請 超 微 讓 控 州 良 軸 找 否 紀 益 依 優 頂 礎 載 倒 房 突 坐 粉 敵 略 客 袁 冷 勝 絕 析 塊 劑 測 絲 協 訴 念 陳 仍 羅 鹽 友 洋 錯 苦 夜 刑 移 頻 逐 靠 混 母 短 皮 終 聚 汽 村 雲 哪 既 距 衛 停 烈 央 察 燒 迅 境 若 印 洲 刻 括 激 孔 搞 甚 室 待 核 校 散 侵 吧 甲 遊 久 菜 味 舊 模 湖 貨 損 預 阻 毫 普 穩 乙 媽 植 息 擴 銀 語 揮 酒 守 拿 序 紙 醫 缺 雨 嗎 針 劉 啊 急 唱 誤 訓 願 審 附 獲 茶 鮮 糧 斤 孩 脫 硫 肥 善 龍 演 父 漸 血 歡 械 掌 歌 沙 剛 攻 謂 盾 討 晚 粒 亂 燃 矛 乎 殺 藥 寧 魯 貴 鐘 煤 讀 班 伯 香 介 迫 句 豐 培 握 蘭 擔 弦 蛋 沉 假 穿 執 答 樂 誰 順 煙 縮 徵 臉 喜 松 腳 困 異 免 背 星 福 買 染 井 概 慢 怕 磁 倍 祖 皇 促 靜 補 評 翻 肉 踐 尼 衣 寬 揚 棉 希 傷 操 垂 秋 宜 氫 套 督 振 架 亮 末 憲 慶 編 牛 觸 映 雷 銷 詩 座 居 抓 裂 胞 呼 娘 景 威 綠 晶 厚 盟 衡 雞 孫 延 危 膠 屋 鄉 臨 陸 顧 掉 呀 燈 歲 措 束 耐 劇 玉 趙 跳 哥 季 課 凱 胡 額 款 紹 卷 齊 偉 蒸 殖 永 宗 苗 川 爐 岩 弱 零 楊 奏 沿 露 桿 探 滑 鎮 飯 濃 航 懷 趕 庫 奪 伊 靈 稅 途 滅 賽 歸 召 鼓 播 盤 裁 險 康 唯 錄 菌 純 借 糖 蓋 橫 符 私 努 堂 域 槍 潤 幅 哈 竟 熟 蟲 澤 腦 壤 碳 歐 遍 側 寨 敢 徹 慮 斜 薄 庭 納 彈 飼 伸 折 麥 濕 暗 荷 瓦 塞 床 築 惡 戶 訪 塔 奇 透 梁 刀 旋 跡 卡 氯 遇 份 毒 泥 退 洗 擺 灰 彩 賣 耗 夏 擇 忙 銅 獻 硬 予 繁 圈 雪 函 亦 抽 篇 陣 陰 丁 尺 追 堆 雄 迎 泛 爸 樓 避 謀 噸 野 豬 旗 累 偏 典 館 索 秦 脂 潮 爺 豆 忽 托 驚 塑 遺 愈 朱 替 纖 粗 傾 尚 痛 楚 謝 奮 購 磨 君 池 旁 碎 骨 監 捕 弟 暴 割 貫 殊 釋 詞 亡 壁 頓 寶 午 塵 聞 揭 炮 殘 冬 橋 婦 警 綜 招 吳 付 浮 遭 徐 您 搖 谷 贊 箱 隔 訂 男 吹 園 紛 唐 敗 宋 玻 巨 耕 坦 榮 閉 灣 鍵 凡 駐 鍋 救 恩 剝 凝 鹼 齒 截 煉 麻 紡 禁 廢 盛 版 緩 淨 睛 昌 婚 涉 筒 嘴 插 岸 朗 莊 街 藏 姑 貿 腐 奴 啦 慣 乘 夥 恢 勻 紗 扎 辯 耳 彪 臣 億 璃 抵 脈 秀 薩 俄 網 舞 店 噴 縱 寸 汗 掛 洪 賀 閃 柬 爆 烯 津 稻 牆 軟 勇 像 滾 厘 蒙 芳 肯 坡 柱 盪 腿 儀 旅 尾 軋 冰 貢 登 黎 削 鑽 勒 逃 障 氨 郭 峰 幣 港 伏 軌 畝 畢 擦 莫 刺 浪 秘 援 株 健 售 股 島 甘 泡 睡 童 鑄 湯 閥 休 匯 舍 牧 繞 炸 哲 磷 績 朋 淡 尖 啟 陷 柴 呈 徒 顏 淚 稍 忘 泵 藍 拖 洞 授 鏡 辛 壯 鋒 貧 虛 彎 摩 泰 幼 廷 尊 窗 綱 弄 隸 疑 氏 宮 姐 震 瑞 怪 尤 琴 循 描 膜 違 夾 腰 緣 珠 窮 森 枝 竹 溝 催 繩 憶 邦 剩 幸 漿 欄 擁 牙 貯 禮 濾 鈉 紋 罷 拍 咱 喊 袖 埃 勤 罰 焦 潛 伍 墨 欲 縫 姓 刊 飽 仿 獎 鋁 鬼 麗 跨 默 挖 鏈 掃 喝 袋 炭 污 幕 諸 弧 勵 梅 奶 潔 災 舟 鑑 苯 訟 抱 毀 懂 寒 智 埔 寄 屆 躍 渡 挑 丹 艱 貝 碰 拔 爹 戴 碼 夢 芽 熔 赤 漁 哭 敬 顆 奔 鉛 仲 虎 稀 妹 乏 珍 申 桌 遵 允 隆 螺 倉 魏 銳 曉 氮 兼 隱 礙 赫 撥 忠 肅 缸 牽 搶 博 巧 殼 兄 杜 訊 誠 碧 祥 柯 頁 巡 矩 悲 灌 齡 倫 票 尋 桂 鋪 聖 恐 恰 鄭 趣 抬 荒 騰 貼 柔 滴 猛 闊 輛 妻 填 撤 儲 簽 鬧 擾 紫 砂 遞 戲 吊 陶 伐 餵 療 瓶 婆 撫 臂 摸 忍 蝦 蠟 鄰 胸 鞏 擠 偶 棄 槽 勁 乳 鄧 吉 仁 爛 磚 租 烏 艦 伴 瓜 淺 丙 暫 燥 橡 柳 迷 暖 牌 秧 膽 詳 簧 踏 瓷 譜 呆 賓 糊 洛 輝 憤 競 隙 怒 粘 乃 緒 肩 籍 敏 塗 熙 皆 偵 懸 掘 享 糾 醒 狂 鎖 淀 恨 牲 霸 爬 賞 逆 玩 陵 祝 秒 浙 貌 役 彼 悉 鴨 趨 鳳 晨 畜 輩 秩 卵 署 梯 炎 灘 棋 驅 篩 峽 冒 啥 壽 譯 浸 泉 帽 遲 矽 疆 貸 漏 稿 冠 嫩 脅 芯 牢 叛 蝕 奧 鳴 嶺 羊 憑 串 塘 繪 酵 融 盆 錫 廟 籌 凍 輔 攝 襲 筋 拒 僚 旱 鉀 鳥 漆 沈 眉 疏 添 棒 穗 硝 韓 逼 扭 僑 涼 挺 碗 栽 炒 杯 患 餾 勸 豪 遼 勃 鴻 旦 吏 拜 狗 埋 輥 掩 飲 搬 罵 辭 勾 扣 估 蔣 絨 霧 丈 朵 姆 擬 宇 輯 陝 雕 償 蓄 崇 剪 倡 廳 咬 駛 薯 刷 斥 番 賦 奉 佛 澆 漫 曼 扇 鈣 桃 扶 仔 返 俗 虧 腔 鞋 棱 覆 框 悄 叔 撞 騙 勘 旺 沸 孤 吐 孟 渠 屈 疾 妙 惜 仰 狠 脹 諧 拋 黴 桑 崗 嘛 衰 盜 滲 臟 賴 湧 甜 曹 閱 肌 哩 厲 烴 緯 毅 昨 偽 症 煮 嘆 釘 搭 莖 籠 酷 偷 弓 錐 恆 傑 坑 鼻 翼 綸 敘 獄 逮 罐 絡 棚 抑 膨 蔬 寺 驟 穆 冶 枯 冊 屍 凸 紳 坯 犧 焰 轟 欣 晉 瘦 禦 錠 錦 喪 旬 鍛 壟 搜 撲 邀 亭 酯 邁 舒 脆 酶 閒 憂 酚 頑 羽 漲 卸 仗 陪 闢 懲 杭 姚 肚 捉 飄 漂 昆 欺 吾 郎 烷 汁 呵 飾 蕭 雅 郵 遷 燕 撒 姻 赴 宴 煩 債 帳 斑 鈴 旨 醇 董 餅 雛 姿 拌 傅 腹 妥 揉 賢 拆 歪 葡 胺 丟 浩 徽 昂 墊 擋 覽 貪 慰 繳 汪 慌 馮 諾 姜 誼 兇 劣 誣 耀 昏 躺 盈 騎 喬 溪 叢 盧 抹 悶 諮 刮 駕 纜 悟 摘 鉺 擲 頗 幻 柄 惠 慘 佳 仇 臘 窩 滌 劍 瞧 堡 潑 蔥 罩 霍 撈 胎 蒼 濱 倆 捅 湘 砍 霞 邵 萄 瘋 淮 遂 熊 糞 烘 宿 檔 戈 駁 嫂 裕 徙 箭 捐 腸 撐 曬 辨 殿 蓮 攤 攪 醬 屏 疫 哀 蔡 堵 沫 皺 暢 疊 閣 萊 敲 轄 鉤 痕 壩 巷 餓 禍 丘 玄 溜 曰 邏 彭 嘗 卿 妨 艇 吞 韋 怨 矮 歇 ;;
    pt?(_*)) echo a{b{a{cate,ixo,lar,ter},duzir,e{lha,rto},ismo,otoar,r{anger,eviar,igar,upto},s{into,oluto,urdo},utre},c{a{bado,lmar,mpar,nhar,so},e{itar,lerar,nar,rvo,ssar,tona},hatar,i{dez,ma,onado,rrar},l{amar,ive},o{lhida,modar,plar,rdar},u{mular,sador}},d{aptar,e{ga,ntro,pto,quar,rente,sivo,us},i{ante,tivo},j{etivo,unto},mirar,orar,quirir,ubo,v{erso,ogado}},eronave,f{astar,e{rir,tivo},i{nador,velar},l{ito,uente},rontar},g{a{char,rrar,salho},enciar,i{lizar,ota,tado},ora,r{adar,este,upar},u{ardar,lha}},j{oelhar,u{dar,star}},l{a{meda,rme,strar,vanca},b{ergue,ino},catra,deia,e{crim,gria,rtar},f{ace,inete},gum,heio,i{ar,cate,enar,nhar,viar},mofada,ocar,piste,t{erar,itude},u{cinar,gar,no,sivo},vo},m{a{ciar,dor,relo,ssar},b{as,iente},e{ixa,nizar},i{do,stoso,zade},o{lador,ntoar,roso,stra},p{arar,liar,ola}},n{a{grama,lisar,rquia,tomia},daime,e{l,xo},gular,imar,jo,o{malia,tado},sioso,terior,u{idade,nciar},zol},p{a{gador,lpar,nhado},e{go,lido,rtada,sar,tite},ito,l{auso,icada},o{io,ntar,sta},r{endiz,ovar}},quecer,r{a{me,nha,ra},cada,dente,e{ia,jar,nito,sta},g{iloso,ola},ma,quivo,r{aial,ebate,iscar,oba,umar},senal,t{erial,igo},voredo},s{faltar,ilado,pirar,s{ador,inar,oalho,unto},tral},t{a{cado,dura,lho,refar},e{ar,nder,rro,u},i{ngir,rador,vo},oleiro,r{acar,evido,iz},u{al,m}},u{ditor,mentar,r{a,ora},t{ismo,oria,uar}},v{a{liar,nte,ria},e{ntal,sso},i{ador,sar},ulso},xila,z{arar,e{do,ite},ulejo}} b{a{b{ar,osa},c{alhau,harel,ia},gagem,i{ano,lar,oneta,rro,xista},jular,l{eia,iza,sa},n{al,deira,ho,ir,quete},r{ato,bado,onesa,raca,ulho},s{eado,tante},t{ata,edor,ida,om,ucar},unilha},e{ber,i{jo,rada,sebol},l{dade,eza,ga,iscar},n{dito,gala,zer},r{imbau,linda,ro},souro,xiga,zerro},i{c{o,udo},enal,f{ocal,urcar},gorna,lhete,m{estre,otor},o{logia,mbo,sfera},polar,rrento,s{coito,neto,po,sexto},tola,zarro},l{indado,o{co,quear}},o{ato,bagem,c{ado,ejo,hecha},icotar,l{ada,etim,ha,o},mbeiro,n{de,eco,ita},r{bulha,da,eal,racha},vino,xeador},r{a{nco,sa,veza},eu,i{ga,lho,ncar},o{a,chura,nzear,to},uxo},u{cha,dismo,far,le,raco,s{ca,to},zina}} c{a{b{ana,elo,ide,o,rito},c{au,etada,horro,ique},d{astro,eado},fezal,i{aque,pira,xote},j{ado,u},l{afrio,cular,deira,ibrar,mante,ota},m{ada,bista,isa,omila,panha,uflar},n{avial,celar,eta,guru,hoto,ivete,oa,sado,tar,udo},p{acho,ela,inar,otar,richo,tador,uz},r{acol,bono,deal,eca,imbar,neiro,pete,reira,taz,valho},s{aco,ca,ebre,telo,ulo},t{arata,ivar},u{le,sador,telar},v{alo,erna}},e{bola,dilha,gonha,l{ebrar,ular},n{oura,so,teio},r{car,rado,teiro,veja},tim,vada},h{a{cota,leira,mado,pada,rme,tice,ve},e{fe,gada,iro,que},i{cote,fre,nelo},o{calho,ver},u{mbo,tar,va}},i{c{atriz,lone},d{ade,reira},ente,gana,mento,n{to,za},r{anda,cuito,urgia},tar},l{areza,ero,icar,one,ube},o{a{do,gir},b{aia,ertor,rar},cada,e{lho,ntro,so},gumelo,i{bir,fa,ote},l{ar,eira,her,idir,meia,ono,una},m{ando,binar,entar,itiva,over,plexo,um},n{cha,dor,ectar,fuso,gelar,hecer,jugar,sumir,trato,vite},operar,p{eiro,iador,o},quetel,r{agem,dial,neta,onha,poral,reio,tejo,uja,vo},s{seno,tela},tonete,u{ro,ve},vil,zinha},r{a{tera,vo},e{che,dor,me,r,spo},i{ada,minal,oulo,se,ticar},osta,u{a,zeiro}},u{bano,eca,idado,jo,l{atra,minar,par,tura},mprir,nhado,pido,r{ativo,ral,sar,to},s{pir,tear},telo}} d{a{masco,tar},e{b{ater,itar,oche,ulhar},c{alque,imal,live,ote,retar},d{al,icado,uzir},f{esa,umar},g{elo,rau,ustar},i{tado,xar},l{ator,egado,inear,onga},m{anda,itir,olido},ntista,p{enado,ilar,ois,ressa,urar},r{iva,ramar},s{afio,botar,canso,enho,fiado,gaste,igual,lize,mamar,ova,pesa,taque,viar},t{alhar,entor,onar,rito},usa,v{er,ido,otado},zena},i{a{grama,leto},data,fuso,gitar,l{atado,uente},minuir,n{astia,heiro},ocese,reto,s{creta,farce,paro,quete,sipar,tante},tador,urno,v{erso,isor,ulgar},zer},o{brador,lorido,m{ador,inado},n{ativo,zela},r{mente,sal},sagem,u{rado,tor}},r{enagem,ible,ogaria},u{e{lar,nde,to},plo,quesa,rante,vidoso}} e{c{lodir,o{ar,logia}},d{i{ficar,tal},ucado},fe{ito,tivar},jetar,l{aborar,e{ger,itor,nco,vador},iminar,ogiar},m{b{argo,olado,rulho,utido},e{nda,rgir},issor,p{atia,enho,inado,olgar,rego,urrar},ulador},n{c{aixe,enado,hente,ontro},d{eusar,ossar},f{aixar,eite,im},g{ajado,enho,lobar,omado,raxar,uia},joar,latar,quanto,r{aizar,olado,ugar},s{aio,eada,ino,opado},t{anto,eado,idade,ortar,rada,ulho},v{ergar,iado,olver},x{ame,erto,ofre,uto}},piderme,quipar,r{eto,guido,rata,v{a,ilha}},s{b{anjar,elto},c{ama,ola,rita,uta},f{inge,olar,regar,umado},grima,malte,p{anto,elho,iga,onja,reita,umar},querda,t{aca,eira,icar,ofado,rela,udo},vaziar},t{anol,iqueta},u{foria,ropeu},v{a{cuar,porar,sivo},entual,idente,oluir},x{a{gero,lar,minar,to,usto},c{esso,itar,lamar},e{cutar,mplo},i{bir,gente},onerar,p{andir,elir,irar,lanar,osto,resso,ulsar},t{erno,into,rato}}} f{a{b{ricar,uloso},c{eta,ial},d{a,iga},ixa,l{ar,ta},miliar,n{dango,farra,toche},r{dado,elo,inha,ofa,pa,tura},t{ia,or},vorita,xina,zenda},e{chado,i{joada,rante},lino,minino,n{da,o},r{a,iado,rugem,ver},stejar,tal,udal},i{apo,brose,c{ar,heiro},gurado,l{eira,ho,me,trar},rmeza,s{gada,sura},ta,vela,x{ador,o}},l{a{cidez,mingo,nela},echada,ora,u{tuar,xo}},o{c{al,inho},focar,g{o,uete},ice,l{gado,heto},r{jar,miga,no,te},s{co,sa}},r{a{gata,lda,ngo,sco,terno},e{ira,nte,tar},i{eza,so,tura},onha,u{strar,teira}},u{gir,l{ano,igem},n{dar,go,il},r{ador,ioso},tebol}} g{a{b{arito,inete},do,i{ato,ola,vota},l{ega,ho,inha,ocha},nhar,r{agem,fo,galo,impo,oupa,rafa},s{oduto,to},t{a,ilho},veta,zela},e{l{ado,eia,o},m{ada,er,ido},n{eroso,giva,ial,oma,ro},ologia,r{ador,minar},s{so,tor}},i{n{asta,cana,gado},r{afa,ino}},l{acial,icose,o{bal,rioso}},o{ela,iaba,l{fe,pear},r{dura,jeta,ro},stoso,teira,vernar},r{a{cejo,dual,fite,lha,mpo,nada,tuito,veto,xa},e{go,lhar,ve},i{lo,salho,taria},o{sso,tesco},u{dado,nhido,ta}},u{a{che,rani,xinim},errear,i{ar,ncho,sado},l{a,oso},ru}} h{a{bitar,rmonia,ste,ver},e{ctare,r{dar,esia},sitar},i{ato,bernar,dratar,ena,no,p{ismo,nose,oteca}},o{je,lofote,mem,n{esto,rado},rmonal,spedar},umorado} i{ate,d{eia,oso},g{norado,reja,uana},l{eso,ha,u{dido,minar,strar}},m{agem,e{diato,nso,rsivo},i{nente,tador},ortal,p{acto,edir,lante,or,rensa,une},unizar},n{a{lador,pto,tivo},c{enso,har,idir,luir,olor},d{eciso,ireto,utor},e{ficaz,rente},f{antil,estar,inito,lamar,ormal,rator},gerir,i{bido,cial,migo},jetar,o{cente,doro,vador,x},quieto,s{crito,eto,istir,petor,talar,ulto},t{acto,egral,imar,ocado,riga},v{asor,erno,icto,ocar}},ogurte,r{aniano,onizar,r{eal,itado}},s{ca,ento,olado,queiro},taliano} j{a{n{eiro,gada,ta},r{araca,dim,ro},smim,to,vali,zida},ejum,o{aninha,elhada,gador,ia,r{nal,rar},vem},u{ba,d{eu,oca},iz,l{gador,ho},r{ado,ista,o},sta}} l{a{b{areda,oral},c{re,tante},drilho,g{arta,oa},je,m{ber,entar,inar,pejo},nche,p{idar,so},r{anja,eira,gura},s{anha,tro},t{eral,ido},v{anda,oura,rador},xante,zer},e{aldade,bre,g{ado,endar,ista},i{go,loar,tura},m{brete,e},n{hador,tilha},oa,s{ma,te},t{ivo,reiro},v{ar,eza,itar}},i{b{eral,ido},derar,g{ar,eiro},m{itar,oeiro,pador},n{da,ear,hagem},quidez,s{tagem,ura},toral,vro,x{a,eira}},o{c{ador,utor},jista,mbo,n{a,ge,tra},rde,t{ado,eria},u{cura,sa,var}},u{ar,c{idez,ro},neta,stre,tador,va}} m{a{c{aco,ete,hado,io},d{eira,rinha},g{nata,reza},i{or,s},l{andro,ha,ote,uco},m{ilo,oeiro,ute},n{ada,cha,dato,equim,hoso,ivela,obrar,sa,ter,usear},peado,quinar,r{cador,esia,fim,gem,inho,mita,oto,quise,reco,telo,ujo},s{cote,morra,sagem,tigar},t{agal,erno,inal,utar},xilar},e{d{alha,ida,usa},gafone,iga,l{ancia,hor},m{bro,orial},n{ino,os,sagem,tal},r{ecer,gulho},s{ada,clar,mo,quita,tre},t{ade,eoro,ragem},x{er,icano}},i{cro,g{alha,rar},l{agre,enar,har},mado,n{erar,hoca,istro,oria},olo,r{ante,tilo},sturar},o{cidade,d{erno,ular},e{da,r},i{nho,ta},l{dura,eza,ho,inete,usco},ntanha,queca,r{ango,cego,domo,ena},s{aico,quete,tarda},t{el,im,o,riz}},u{da,ito,l{ata,her,tar},n{dial,ido},r{alha,cho},s{cular,eu,ical}}} n{a{cional,dador,ja,moro,r{ina,rado},scer,t{iva,ureza},v{alha,egar,io}},e{b{lina,uloso},g{ativa,ociar,rito},rvoso,ta,ural,v{asca,oeiro}},i{n{ar,ho},tidez,velar},o{breza,i{te,va},m{ear,inal},r{deste,tear},t{ar,iciar,urno},v{elo,ilho,o}},u{blado,dez,meral,pcial,trir,vem}} o{b{cecado,edecer,jetivo,rigado,s{curo,tetra},t{er,urar}},c{i{dente,oso},orrer,u{lista,pado}},f{e{gante,nsiva,renda},icina,uscado},giva,l{aria,eoso,har,iveira},m{bro,elete,i{sso,tir}},n{dulado,eroso,tem},p{cional,erador,o{nente,rtuno,sto}},r{ar,bitar,d{em,inal},fanato,g{asmo,ulho},i{ental,gem,undo},la,todoxo,valho},s{cilar,s{ada,o},tentar},timismo,u{sadia,t{ono,ubro},vido},v{elha,ular},xi{dar,genar}} p{a{c{ato,iente,ote,tuar},d{aria,rinho},g{ar,ode},i{nel,rar,sagem},l{avra,estra,heta,ito,mada,pitar},n{cada,ela,fleto,queca,tanal},p{agaio,elada,iro},r{afina,cial,dal,ede,tida},s{mo,sado,tel},t{amar,ente,inar,rono},u{lada,sar}},e{culiar,d{alar,estre,iatra,ra},gada,i{toral,xe},l{e,icano},n{ca,durar,eira,hasco,sador,te},r{ceber,feito,gunta,ito,mitir,na,plexo,siana,tence,uca},s{cado,quisa,soa},tiscar},i{ada,cado,edade,gmento,l{astra,hado,otar},menta,n{cel,guim,ha,ote,tar},oneiro,poca,quete,r{anha,es,ueta},s{car,tola},tanga,vete},l{a{nta,queta,tina},ebeu,u{magem,vial}},neu,o{da,e{ira,tisa},l{egada,iciar,uente,vilho},m{ar,ba},n{derar,taria},puloso,rta,s{suir,tal},te,u{par,so},voar},r{a{ia,ncha,to,xe},e{ce,dador,feito,miar,nsar,parar,silha,texto,venir,zar},i{mata,ncesa,sma,vado},o{cesso,duto,feta,ibido,jeto,meter,pagar,sa,tetor,vador}},u{blicar,dim,l{ar,monar,seira},n{hal,ir},pilo,reza,xador}} qu{a{dra,ntia,rto,se},e{brar,da,ijo,nte,rido},i{mono,na,osque}} r{a{b{anada,isco},c{har,ionar},dial,i{ar,nha,o,va},jada,lado,mal,n{ger,hura},p{adura,el,idez,osa},quete,ridade,s{ante,cunho,gar,pador,teira,urar},t{azana,oeira}},e{a{leza,nimar,ver},b{aixar,elde,olar},c{ado,ente,heio,ibo,ordar,rutar,uar},d{e,imir,onda,uzida},envio,f{inar,letir,ogar,resco,ugiar},g{alia,ime,ra},i{nado,tor},jeitar,lativo,m{ador,endo,orso},novado,p{aro,elir,leto,olho,resa,udiar},querer,s{enha,friar,gatar,idir,olver,peito,saca,tante,umir},t{alho,er,irar,omada,ratar},v{elar,isor,olta}},i{acho,ca,g{idez,oroso},mar,ngue,s{ada,co,onho}},o{balo,chedo,d{ada,eio,ovia},edor,leta,mano,ncar,s{ado,eira,to},t{a,eiro,ina,ular},u{co,pa},xo},u{bro,g{ido,oso},ivo,mo,pestre,sso}} s{a{bor,c{iar,ola,udir},dio,fira,g{a,rada},ibro,l{ada,eiro,gado,iva,picar,sicha,tar,vador},m{bar,urai},n{ar,fona,gue,idade},pato,r{da,gento,jeta},turar,udade,xofone,zonal},e{c{ar,ular},d{a,ento,iado,oso,utor},g{mento,redo,undo},iva,l{eto,vagem},m{anal,ente},n{ador,hor,sual,tado},parado,r{eia,inga,ra,vo},t{embro,or}},i{gilo,l{hueta,icone},m{etria,patia,ular},n{al,cero,gular,opse,tonia},r{ene,i},tuado},o{b{erano,ra},corro,gro,ja,l{da,etrar,teiro},mbrio,n{ata,dar,egar,hador,o},prano,quete,r{rir,teio},ssego,t{aque,errar},vado,zinho},u{avizar,b{ida,merso,solo,trair},c{ata,esso,o},deste,fixo,g{ador,erir},jeito,lfato,mir,or,p{erior,licar,osto,rimir},r{dina,fista,presa,real,tir},s{piro,tento}}} t{a{b{ela,lete,uada},cho,garela,l{her,o,vez},m{anho,borim,pa},n{gente,to},p{ar,ioca},r{dio,efa,ja,raxa},tuagem,urino,x{ativo,ista}},e{atral,c{er,ido,lado},dioso,i{a,mar},l{efone,hado},mpero,n{ente,sor,tar},r{mal,no,reno},s{e,oura,tado},to,x{tura,ugo}},i{ara,gela,jolo,m{brar,idez},n{gido,teiro},ragem,tular},o{alha,cha,l{erar,ice},m{ada,ilho},n{el,tura},pete,r{a,cido,neio,que,rada,to},star,u{ca,peira},xina},r{a{balho,cejar,dutor,fegar,jeto,ma,ncar,po,seiro,tador,var},e{ino,mer,pidar,vo},i{agem,bo,ciclo,dente,logia,ndade,plo,turar,unfal},o{car,mbeta,va},u{nfo,que}},u{bular,cano,do,lipa,pi,r{bo,ma,quesa},t{elar,orial}}} u{ivar,mbigo,n{ha,i{dade,forme}},r{ologia,so,tiga,ubu},s{ado,ina,ufruir}} v{a{cina,diar,garoso,idoso,l{a,ente,idade,ores},ntagem,queiro,r{anda,eta,rer},s{cular,ilha,soura},z{ar,io}},e{ado,dar,getar,icular,l{eiro,hice,udo},n{cedor,daval,erar,tre},r{bal,dade,eador,gonha,melho,niz,sar,tente},s{pa,tido},torial},i{a{duto,gem,jar,tura},brador,d{eira,raria},ela,g{a,ente,iar,orar},larejo,n{co,heta,il},oleta,r{ada,tude},s{itar,to},tral,veiro,zinho},o{a{dor,r},gal,l{ante,eibol,tagem,umoso},ntade},u{lto,vuzela}} x{a{drez,rope},e{que,r{etar,ife}},ingar} z{a{ngado,rpar},e{bu,lador},o{mbar,ologia},umbido} ;;
    it?(_*)) echo a{b{aco,b{aglio,inato},ete,isso,olire,r{asivo,ogato}},c{c{adere,enno,usato},etone,hille,ido,qua,r{e,ilico,obata},uto},d{agio,d{ebito,ome},e{guato,rire},ipe,ottare,ulare},f{f{abile,etto,isso,ranto},o{risma,so},ricano},g{ave,e{nte,vole},gancio,i{re,tare},onismo,r{icolo,umeto},uzzo},l{a{barda,to},b{atro,erato,o,ume},c{e,olico},ettone,fa,gebra,i{ante,bi,mento},l{agato,egro,ievo,odola,usivo},meno,ogeno,p{aca,estre},t{alena,erno,iccio,rove},unno,veolo,zare},m{a{lgama,nita,rena},b{ito,rato},e{ba,rica,tista},ico,m{asso,enda,irare,onito},ore,p{io,liare},uleto},n{a{cardo,grafe,lista,rchia,tra},c{a,ella,ora},d{are,rea},ello,g{elo,olare,usto},ima,n{egare,idato,o,uncio},onimo,ticipo,zi},p{atico,ertura,ode,p{arire,etito,oggio,rodo,unto},rile},r{a{bica,chide,gosta,ldica,ncio,tura,zzo},bitro,chivio,dito,enile,g{ento,ine,uto},ia,monia,nese,r{edato,inga,osto},s{enico,o},tefice,zillo},s{c{iutto,olto},e{psi,ttico},falto,ino,ola,p{irato,ro},s{aggio,e,oluto,urdo},t{a,enuto,ice,ratto}},t{avico,eismo,o{mico,no},t{esa,ivare,orno,rito,uale}},u{s{ilio,tria},t{ista,onomo,unno}},v{anzato,ere,v{enire,iso,olgere}},z{ione,oto,z{imo,urro}}} b{a{bele,c{cano,ino,o},d{essa,ilata},gnato,ita,l{cone,do,ena,lata,zano},mbino,ndire,r{aonda,baro,ca,itono,lume,occo},s{ilico,so},t{osta,tuto},ule,v{a,osa}},e{cco,ffa,l{gio,va},n{da,evole,igno,zina},r{e,lina},ta},i{bita,ci,done,fido,ga,lancia,mbo,nocolo,ologo,p{ede,olare},r{bante,ra},s{cotto,esto,nonno,onte,turi},zzarro},la{ndo,tta},o{llito,nifico,rdo,sco,t{anico,tino},zzolo},r{a{ccio,dipo,ma,nca,vura},e{tella,vetto,zza},i{glia,llante,ndare},o{ccolo,do,nzina},u{llo,no}},u{bbone,ca,dino,ffone,io,lbo,ono,r{lone,rasca},s{sola,ta}}} c{a{d{etto,uco},l{amaro,colo,esse,ibro,mo,oria},m{busa,erata,icia,mino,ola,pale},n{apa,dela,e,ino,otto,tina},p{ace,ello,itolo,ogiro,pero,ra,sula},r{apace,cassa,do,isma,ovana,retto,tolina},s{accio,cata,erma,o,sone,tello,uale},t{asta,ena,rame},uto,villo},e{d{ibile,rata},falo,l{ebre,lulare},n{a,one,tesimo},r{amica,care,to,ume,vello},s{oia,po},to},h{ela,i{aro,cca,edere,mera,na,rurgo,tarra}},i{ao,clismo,frare,gno,lindro,ottolo,r{ca,rosi},t{rico,tadino},uffo,v{etta,ile}},l{assico,inica,oro},o{cco,d{ardo,ice},erente,gnome,l{lare,mato,ore,poso,tivato,za},m{a,eta,mando,odo,puter,une},n{ciso,durre,ferma,gelare,iuge,nesso,oscere,sumo,tinuo,vegno},p{erto,ione,pia,ricapo},r{azza,data,icato,nice,olla,po,redo,sia,tese},s{mico,tante},ttura,vato},r{a{tere,vatta},e{ato,dere,moso,scita,ta},i{ceto,nale,si,tico},o{ce,naca,stata},u{ciale,sca}},u{c{ire,ulo},gino,llato,pola,r{atore,sore,vo},s{cino,tode}}} d{a{do,ino,lmata,merino,n{iela,noso,zare},tato,v{anti,vero}},e{butto,c{ennio,iso,lino,ollo,reto},dicato,f{inito,orme},gno,l{egare,fino,irio,ta},menza,n{otato,tro},posito,r{apata,ivare,oga},s{critto,erto,iderio,umere},tersivo,voto},i{ametro,cembre,edro,f{eso,fuso},g{erire,itale},luvio,n{amico,nanzi},p{into,loma,olo},r{adare,e,otto,upo},s{agio,creto,fare,gelo,posto,tanza,umano},to,v{ano,elto,idere,orato}},o{blone,cente,g{anale,ma},lce,m{ato,enica,inare},n{dolo,o},rmire,t{e,tore},vuto,zzina},r{ago,uido},u{b{bio,itare},cale,na,omo,plice,raturo}} e{bano,c{c{esso,o},lissi,onomia},d{era,i{cola,le,toria},ucare},g{emonia,li,oismo,regio},l{a{borato,rgire},e{gante,ncato,tto,vare},fico,ica,mo,sa,uso},m{anato,blema,esso,iro,o{tivo,zione},pirico,ulo},n{d{emico,uro},ergia,fasi,oteca,trare,zima},p{atite,i{logo,sodio},ocale,pure},quatore,r{ario,b{a,oso},e{de,mita},igere,metico,o{e,sivo},rante},s{a{gono,me,nime,udire},ca,e{mpio,rcito},i{bito,gente,stere,to},o{fago,rtato,so},p{anso,resso},s{enza,o},t{eso,imare,onia,roso},ultare},t{ilico,nico,rusco,to},u{clideo,ropa},v{aso,i{denza,tato},oluto,viva}} f{a{bbrica,c{cenda,hiro},lco,miglia,n{ale,fara,go,tasma},r{e,falla,inoso,maco},s{cia,toso,ullo},t{icare,o},voloso},e{bbre,cola,de,gato,l{pa,tro},mmina,n{dere,omeno},r{mento,ro,tile},s{sura,tivo},tta,udo},i{aba,ducia,fa,gurato,lo,n{anza,estra,ire},ore,s{cale,ico},ume},l{a{cone,menco},e{bo,mma},orido,u{ente,oro}},o{bico,c{accia,oso},derato,glio,l{ata,clore,gore},n{dente,etico,ia,tana},r{bito,chetta,esta,mica,naio,o,tezza,zare},s{fato,so}},r{a{casso,na,ssino,tello},e{ccetta,nata,sco},igo,o{llino,nde},u{gale,tta}},u{c{ilata,sia},ggente,l{mine,vo},m{ante,etto,oso},n{e,zione},oco,r{bo,gone,ore},so,tile}} g{a{bbiano,ffe,l{ateo,lina,oppo},m{bero,ma},r{anzia,bo,ofano,zone},s{dotto,olio,trico},tto,udio,z{ebo,zella}},e{co,l{atina,so},m{ello,mato},n{e,itore,naio,otipo},rgo},h{epardo,i{accio,sa}},i{allo,lda,nepro,o{care,iello,rno,ve},r{ato,one},ttata,u{dizio,rato,sto}},l{obulo,utine},nomo,o{bba,lf,m{ito,mone},n{fio,na},verno},r{a{cile,do,fico,mmo,nde,ttare,voso,zia},e{ca,gge},i{fone,gio,nza},otta,uppo},u{a{dagno,io,nto,rdare},fo,idare}} i{bernato,cona,d{entico,illio,olo,r{a,ico,ogeno}},g{iene,n{aro,orato}},l{are,l{eso,ogico,udere}},m{b{allo,evuto,occo,uto},m{ane,erso,olato},p{acco,eto,iego,orto,ronta}},n{a{lare,rcare,ttivo},c{anto,endio,hino,isivo,luso,ontro,rocio,ubo},d{agine,ia,ole},edito,f{atti,ilare,litto},g{aggio,egno,lese,ordo,rosso},nesco,o{dore,ltrare,ndato},s{ano,etto,ieme,onnia,ulina},t{asato,ero,onaco,uito},umidire,v{alido,ece,ito}},p{erbole,notico,otesi,pica},r{ide,landa,onico,r{igato,orare}},s{o{lato,topo},t{erico,ituto,rice}},t{alia,erare}} l{a{b{bro,irinto},c{ca,erato,rima,una},ddove,go,mpo,n{cetta,terna},r{doso,ga,inge},stra,t{enza,ino,tuga},v{agna,oro}},e{g{ale,gero},mbo,n{tezza,za},one,pre,s{ivo,sato,to},tterale,v{a,igato}},i{bero,do,evito,lla,m{atura,itare,pido},n{eare,gua},quido,r{a,ica},sca,t{e,igio},vrea},o{canda,de,gica,mbare,n{dra,gevo},quace,renzo,t{o,teria}},u{c{e,idato},m{aca,inoso},ngo,p{o,polo},s{inga,so},tto}} m{a{c{abro,china,ero,inato},dama,g{ico,lia,nete,ro},iolica,l{afede,grado,inteso,sano,to,umore},n{a,cia,dorla,giare,ifesto,naro,ovra,sarda,tide,ubrio},ppa,r{atona,cire,etta,mo,supio},s{chera,saia,tino},t{erasso,ricola,tone,uro},zurca},e{andro,c{canico,enate},d{esimo,itare},ga,l{assa,is,odia},n{inge,o,sola},r{curio,enda,lo},s{chino,e,sere,tolo},t{allo,odo,tere}},i{agolare,c{a,elio,hele,robo},dollo,ele,gliore,l{ano,ite},mosa,n{erale,i,ore},r{ino,tillo},s{cela,siva,to,urare},t{ezza,igare,ra,tente}},nemonico,o{d{ello,ifica,ulo},g{ano,io},l{e,osso},n{astero,co,dina,etario,ile,otono,sone,tato,viso},r{a,dere,sicato},stro,t{ivato,osega,to},v{enza,imento},zzo},u{c{ca,osa},ffa,g{hetto,naio},l{atto,inello,tiplo},mmia,nto,overe,rale,s{a,colo,ica},t{evole,o}}} n{a{babbo,fta,nometro,r{ciso,ice,rato},s{cere,trare},turale,utica,viglio},e{bulosa,crosi,g{ativo,ozio},mmeno,ofita,r{etto,vo},ssuno,ttuno,utrale,v{e,rotico}},i{cchia,nfa,tido},o{bile,civo,do,m{e,ina},r{dico,male,vegese},strano,t{are,izia,turno},vella},u{cleo,lla,mero,ovo,trire,vola,ziale}} o{asi,b{b{edire,ligo},elisco,lio,olo,soleto},c{c{asione,hio,idente,orrere,ultare},ra,ulato},d{ierno,orare},ff{erta,rire,uscato},g{g{etto,i},nuno},l{andese,fatto,i{ato,va},ogramma,tre},m{aggio,b{elico,ra},ega,issione},n{doso,ere,ice,nivoro,orevole,ta},p{erato,inione,posto},r{a{colo,fo},dine,e{cchino,fice},fano,ganico,i{gine,zzonte},m{a,eggio},nativo,ologio,r{endo,ibile},t{ensia,ica},z{ata,o}},s{are,curare,mosi,p{edale,ite},s{a,idare},t{acolo,e}},t{ite,re,t{agono,imo,obre}},v{ale,est,i{no,paro},ocito,unque,viare},zio} p{a{c{chetto,e,ifico},d{ella,rone},ese,g{a,ina},l{azzina,esare,lido,o,ude},n{doro,nello},o{lo,nazzo},prica,r{abola,cella,ere,golo,i,lato,ola,tire,venza,ziale},s{sivo,ticca},t{acca,ologia,tume},vone},e{ccato,d{alare,onale},ggio,loso,n{are,dice,isola,nuto,ombra,sare,tola},p{e,ita},r{bene,corso,donato,forare,gamena,iodo,messo,no,plesso,suaso,tugio,vaso},s{atore,ista,o,tifero},t{alo,tine,ulante},zzo},i{a{cere,nta,ttino},c{cino,ozza},e{ga,tra},ffero,g{iama,olio,ro},l{a,ifero,lola,ota},mpante,n{eta,na,olo},o{ggia,mbo},r{amide,etico,ite,olisi},tone,zzico},l{a{cebo,nare,sma,tano},enario},o{chezza,d{eroso,ismo},esia,ggiare,l{enta,igono,lice,monite,petta,so,trona,vere},m{ice,odoro},nte,poloso,r{fido,oso,pora,re,tata},s{a,itivo,sesso,tulato},t{assio,ere}},r{a{nzo,ssi,tica},e{cluso,dica,fisso,giato,lievo,mere,notare,parato,senza,testo,valso},i{ma,ncipe,vato},o{blema,cura,durre,fumo,getto,lunga,messa,nome,posta,roga,teso,va},u{dente,gna,rito}},siche,u{bblico,dica,g{ilato,no},l{ce,ito,sante},ntare,p{azzo,illa},ro}} qu{a{dro,lcosa,si},erela,ota} r{a{ccolto,d{doppio,icale,unato},ffica,g{azzo,ione,no},m{arro,ingo,o},n{dagio,tolare},p{ato,ina,preso},s{atura,chiato,ente,segna,trello},ta,vveduto},e{ale,c{epire,into,luta,ondito,upero},d{dito,imere},g{alato,istro,ola,resso},lazione,m{are,oto},nna,p{lica,rimere,utare},s{a,idente,ponso,tauro},t{e,ina,orica,tifica},vocato},i{assunto,b{adire,elle,rezzo},c{arica,co,evere,iclato,ordo,reduto},d{icolo,urre},f{asare,lesso,orma,ugio},g{are,ettato,hello},l{assato,evato},m{anere,balzo,edio,orchio},n{ascita,caro,forzo,novo,omato,savito,tocco,uncia,venire},p{arato,etuto,ieno,ortare,resa,ulire},s{ata,chio,erva,ibile,o,petto,toro,ultato,volto},t{ardo,egno,mico,rovo},unione,v{a,erso,incita,olto},zoma},o{b{a,otico,usto},c{cia,o},d{aggio,ere,itore},gito,llio,m{antico,pere},nzio,s{olare,po},t{ante,ondo,ula},vescio},u{b{izzo,rica},ga,llino,m{ine,oroso},olo,pe,s{sare,tico}}} s{a{b{ato,biare,otato},goma,l{asso,datura,gemma,ivare,mone,one,tare,uto,vo},p{ere,ido,orito},r{aceno,casmo,to},ssoso,t{ellite,ira,ollo,urno},v{ana,io},ziato},b{a{diglio,lzo,ncato,rra,ttere,vare},endare,irciare,loccato,occiato,r{inare,uffone},uffare},c{a{broso,denza,la,mbiare,ndalo,pola,rso,tenare,vato},e{lto,nico,ttro},h{eda,iena},i{arpa,enza,ndere,ppo,roppo,volo},lerare,o{della,lpito,mparto,nforto,prire,rta,ssone,zzese},r{iba,ollare,utinio},u{deria,ltore,ola,ro,sare}},d{ebitare,oganare},e{c{catura,ondo},dano,g{giola,nalato,regato,uito},l{ciato,ettivo,la,vaggio},m{aforo,brare,e,inato,pre},n{so,tire},polto,quenza,r{ata,bato,eno,io,pente,raglio,vire},stina,t{ola,timana}},f{a{celo,ldare,mato,rzoso,ticato},era,i{da,lato,nge},o{cato,derare,go,ltire,rzato},r{atto,uttato},u{ggito,mare,so}},g{a{bello,rbato},o{nfiare,rbio},rassato,uardo},i{bilo,ccome,erra,g{la,nore},l{enzio,laba},m{bolo,patico,ulato},n{fonia,golo,istro,o,tesi,usoide},pario,s{ma,tole},tuato},l{itta,o{gatura,veno}},m{arrito,e{morato,ntito,raldo},ilzo,o{ntare,ttato},ussato},n{e{llire,rvato},odo},o{b{balzo,rio},c{corso,iale},dale,ffitto,gno,l{dato,enne,ido,lazzo,o,ubile,vente},m{atico,ma},n{da,etto,nifero},p{ire,peso,ra},r{gere,passo,riso,so,teggio,volato},s{piro,ta},ttile},p{a{da,lla,rgere,tola,vento,zzola},e{cie,dire,gnere,latura,ranza,ssore,ttrale,zzato},i{a,goloso,llato,noso,rale},lendido,o{rtivo,so},r{anga,ecare,onato,uzzo},untino},quillo,r{adicare,otolato},t{a{bile,cco,ffa,gnare,mpato,ntio,rnuto,sera,tuto},e{lo,ppa,rzo},i{letto,ma,rpe,vale,zzoso},o{nato,rico},r{appo,egato,idulo,ozzare,utto},u{ccare,fo,pendo}},u{bentro,ccoso,dore,g{gerito,o},ltano,onare,p{erbo,porto},r{gelato,rogato},ssurro,tura},v{agare,e{dese,glio,lare,nuto,zia},i{luppo,sta,zzera},olta,uotare}} t{a{b{acco,ulato},c{ciare,iturno},l{e,ismano},mpone,nnino,r{a,divo,gato,iffa,pare,taruga},sto,ttico,v{erna,olata},zza},e{c{a,nico},lefono,m{erario,po,uto},n{done,ero,sione,tacolo},orema,r{me,razzo,zetto},s{i,serato,tato},t{ro,toia}},i{fare,gella,mbro,nto,p{ico,ografo},r{aggio,o},t{anio,olo,ubante},z{io,zone}},o{ccare,l{lerare,to},m{bola,o},n{fo,silla},p{azio,ologia,pa},r{ba,nare,rone,tora},s{cano,sire,tatura},tano},r{a{bocco,chea,fila,gedia,lcio,monto,nsito,pano,rre,sloco,ttato,ve},e{ccia,molio,spolo},i{buto,checo,foglio,llo,ncea,o,stezza,turato,vella},o{mba,no,ppo,ttola,vare},uccato},u{batura,ffato,lipano,multo,nisia,r{bare,chino},t{a,ela}}} u{bicato,cc{ello,isore},di{re,tivo},ff{a,icio},guale,l{isse,timato},m{ano,ile,orismo},n{cinetto,g{ere,herese},i{corno,ficato,sono,tario},te},ovo,pupa,r{agano,genza,lo},s{a{nza,to},cito,ignolo,uraio},t{ensile,ilizzo,opia}} v{a{c{ante,cinato},g{abondo,liato},l{anga,go,ico,letta,oroso,utare,vola},mpata,n{gare,itoso,o,taggio,vera},pore,r{ano,cato,iante},sca},e{d{etta,ova,uto},getale,icolo,l{cro,ina,luto,oce},n{ato,demmia,to},r{ace,bale,gogna,ifica,o,ruca,ticale},s{cica,sillo,tale},t{erano,rina,usto}},i{andante,brante,c{enda,hingo,inanza},dimare,g{ilia,neto,ore},l{e,lano},mini,ncitore,ola,pera,r{gola,ologo,ulento},s{coso,ione,po,suto,ura},t{a,ello,tima},v{anda,ido},ziare},o{ce,ga,l{atile,ere,pe},ragine},ulcano} z{a{mpogna,nna,ppato,ttera,vorra},e{firo,l{ante,o},nzero,rbino},i{betto,nco,rcone,tto},o{lla,tico},u{cchero,folo,lu,ppa}} ;;
    cs?(_*)) echo a{b{dikace,eceda},dresa,grese,k{ce,tovka},l{ej,kohol},mputace,n{anas,dulka,ekdota,keta,tika,ulovat},r{cha,ogance},s{falt,istent,pirace,t{ma,ronom}},t{l{as,etika},ol},utobus,zyl} b{a{bka,c{hor,il,ulka},datel,g{eta,r},hno,kterie,l{ada,etka,kon,onek,van,za},mbus,nkomat,r{bar,et,man,oko,va},t{erka,oh},vlna,z{alka,ilika,uka}},e{dna,ran,s{eda,tie},ton,z{inka,moc,tak}},i{cykl,dlo,ftek,kiny,lance,o{graf,log},tva,zon},l{a{hobyt,touch},e{cha,dule,sk},i{kat,zna},o{kovat,udit},ud},o{b{ek,r},d{lina,nout},hatost,j{kot,ovat},korys,lest,r{ec,ovice},ta,u{bel,chat,da,le,rat},xer},r{a{davka,mbora,nka,tr},epta,iketa,ko,loh,o{nz,skev},u{netka,sinka},z{da,y}},u{b{lina,novat},chta,d{itel,ka,ova},fet,jarost,kvice,l{dok,va},n{da,kr},rza,tik,vol,zola},y{dlet,lina,tovka},zukot} c{a{part,revna},e{d{r,ule},j{ch,n},l{a,er,kem,nice},n{ina,nost,ovka,trum,zor},stopis,tka},h{a{lupa,padlo,rita,ta},e{chtat,mie},i{chot,rurg},l{ad,eba,ubit},m{el,ura},o{bot,chol,dba,lera,mout,pit,roba,v},r{apot,lit,t,up},tivost,u{dina,tnat},v{at,ilka,ost},y{ba,stat,tit}},i{bule,gareta,h{elna,la},nkot,rkus,sterna,t{ace,rus},z{inec,ost}},lona,o{koliv,uvat},t{itel,nost},u{dnost,k{eta,r},pot},v{a{knout,l},ik,rkot},yklista} d{a{leko,reba,t{el,um}},cera,e{bata,c{hovka,ibel},f{icit,lace},k{l,ret},mokrat,prese,rby,ska,tektiv},i{k{obraz,tovat},oda,plom,s{k,plej},v{adlo,och}},l{aha,ouho,uhopis},nes,o{b{ro,ytek},c{ent,hutit},dnes,h{led,oda,ra},j{em,nice},k{lad,ola,tor,ument},l{ar,eva,ina},m{a,inant,luvit,ov},nutit,p{ad,is,lnit,osud,rovod,ustit},r{azit,ost,t},s{ah,lov,tatek,ud,yta},t{az,ek,knout},u{fat,tnat},vozce,z{adu,nat,orce}},r{a{hota,k,matik,vec,ze},dol,o{bnost,gerie,zd},snost,tit,zost},u{ben,chovno,dek,h{a,ovka},s{it,no},tost},vo{jice,rec},ynamit} e{ko{log,nomie},l{ektron,ipsa},m{ail,ise,oce,patie},p{izoda,o{cha,pej,s}},s{e{j,nce},k{orta,ymo}},tiketa,uforie,voluce,x{ekuce,kurze,p{edice,loze,ort},trakt}} f{a{cka,jfka,kulta,n{atik,tazie},rmacie,vorit,zole},e{derace,jeton,nka},i{alka,gurant,l{ozof,tr},n{ance,ta},xace},jord,l{anel,irt,otila},o{nd,sfor,t{bal,ka,on}},r{akce,eska,onta},u{kar,nkce},yzika} g{a{leje,rant},e{netika,olog},ilotina,l{azura,ejt},o{l{em,fista},tika},r{a{f,mofon,nule},ep,il,o{g,teska}},uma} h{a{d{ice,r},l{a,enka},n{ba,opis},r{fa,puna},vran},e{bkost,j{kal,no,tman},ktar,lma,matom,r{ec,na},slo,zky},istorik,l{a{dovka,sivky,va},e{dat,n},o{davec,h,upost},tat,u{bina,chota}},m{at,ota,yz},n{is,o{jivo,ut}},o{b{lina,oj},ch,d{iny,lat,nota,ovat},jnost,kej,l{inka,ka,ub},mole,n{itba,orace},r{al,da,izont,ko,livec,mon,nina,oskop,stvo},s{poda,tina},tovost,u{ba,f,pat,ska},vor},r{a{dba,nice,vost,zda},bolek,d{ina,lo,ost},nek,o{bka,mada,t,uda,zen},stka,ubost,yzat},u{b{enost,nout},dba,kot,mr,s{ita,tota}},vozd,y{bnost,drant,giena,mna,sterik}} i{dylka,hned,kona,luze,munita,n{f{ekce,lace},kaso,ovace,spekce,ternet,v{alida,estor},zerce},ronie} j{a{blko,chta,hoda,k{mile,ost},lovec,ntar,r{mark,o},s{an,no},tka,vor,zyk},e{d{inec,le,natel},hlan,kot,l{en,ito},mnost,nom,pice,seter,vit,z{dec,ero}},i{n{ak,dy,och},s{kra,tota},trnice,zva},menovat,ogurt,urta} k{a{b{aret,el,inet},chna,d{et,idlo},han,j{ak,uta},k{ao,tus},l{amita,hoty,ibr,nost},m{era,koliv,na},n{ibal,oe,tor},p{alina,ela,itola,ka,le,ota,r,usta,ybara},r{amel,otka,ton},sa,t{alog,edra},u{ce,za},valec,z{ajka,eta,ivost}},de{koliv,si},e{dluben,mp,ramika},ino,l{a{cek,divo,m,pot,sika,un},e{c,nba,pat,snout},i{d,ma,sna},o{bouk,kan,pa,ub},u{bovna,sat,zkost}},m{en,itat,otr},n{iha,ot},o{alice,b{erec,ka,liha,yla},cour,hout,jenec,k{os,tejl},l{aps,eda,ize,o},m{ando,eta,ik,nata,ora,pas,unita},n{at,cept,dice,ec,fese,gres,ina,kurs,takt,zerva},p{anec,ie,nout,rovka},r{bel,ektor,midlo,optev,pus,una,yto,zet},s{atec,tka},t{el,leta,oul},u{kat,pelna,sek,zlo},vboj,z{a,oroh}},r{a{bice,ch,jina,lovat,sopis,vata},e{dit,jcar,sba,veta},i{ket,tik,ze},kavec,m{elec,ivo},o{can,k,nika,pit,upa,vka},tek,u{hadlo,pice,tost},vinka,y{chle,pta,stal,t}},u{dlanka,fr,jnost,kla,l{ajda,ich,ka,omet,tura},na,podivu,r{t,zor},til},v{a{lita,sinka},estor},y{nolog,selina,t{ara,ice,ka,ovec},vadlo}} l{a{brador,chtan,dnost,ik,komec,m{ela,pa},novka,s{ice,o,tura},tinka,vina},e{bka,ckdy,d{en,nice,ovka,vina},g{enda,ie,race},h{ce,kost,nout},ktvar,n{ochod,tilka},p{enka,idlo},t{adlo,ec,mo,okruh},v{hart,itace,obok}},i{bra,chotka,d{ojed,skost},hovina,javec,lek,metka,n{ie,ka,oleum},stopad,t{ina,ovat}},o{bista,divod,g{ika,oped},k{alita,et},mcovat,p{ata,uch},rd,sos,tr,u{dal,h,ka,skat},vec},stivost,u{c{erna,ifer},mp,s{k,trace}},vice,y{r{a,ika},sina}} m{a{d{am,lo},gistr,hagon,j{etek,itel,orita},k{ak,ovice,rela},l{ba,ina,ovat,vice},minka,n{dle,ko},rnost,s{akr,kot,opust},t{ice,rika,urita},z{anec,ivo,lit,urka}},dloba,e{chanik,d{itace,ovina},l{asa,oun},ntolka,t{la,oda,r},zera},i{grace,h{nout,ule},k{ina,rofon},l{enec,imetr,ost},mika,n{covna,ibar,omet,ulost},s{ka,tr},xovat},l{adost,h{a,ovina},ok,sat,uvit},n{ich,ohem},o{bil,cnost,d{elka,litba},hyla,kro,lekula,mentka,n{archa,okl,strum,tovat,zun},s{az,kyt,t},t{ivace,orka,yka},u{cha,drost},z{aika,ek,ol}},r{a{mor,venec},kev,tvola,z{et,utost}},stitel,u{drc,flon,lat,mie,nice,set,tace,z{eum,ikant}},yslivec,zda} n{a{bourat,chytat,d{ace,bytek,hoz,obro,pis},h{las,nat,odile,radit},ivita,j{ednou,isto,mout},k{lonit,onec,rmit},levo,m{azat,luvit},nometr,o{ko,pak,stro},p{adat,evno,lnit,nout,osled,rosto},r{odit,uby,ychlo},s{adit,ekat,lepo,tat},tolik,v{enek,rch,zdory},zvat},e{be,c{hat,ky},d{aleko,bat,uh},gace,h{et,oda},j{en,prve},klid,libost,m{ilost,oc},o{chota,nka},pokoj,r{ost,v},s{mysl,oulad},tvor,uron,vina,zvykle},i{cota,jak,k{am,dy,l,terak},tro},o{cleh,havice,minace,r{a,ek},s{itel,nost},uze,v{iny,ota},zdra},u{d{a,le},get,t{it,nost,rie}},ymfa} o{b{a{l,rvit,va},div,e{c,hnat,jmout,zita},hajoba,ilnice,j{asnit,ekt},klopit,l{ast,ek,iba,oha,uda},nos,o{hatit,jek,ut},r{azec,na,uba,ys},s{ah,luha,tarat},uv,v{az,init,od,ykle},yvatel,zor},c{as,e{l,nit},h{ladit,ota,rana},itnout},d{b{oj,yt},c{hod,izit},e{brat,slat,vzdat,zva},h{adce,odit},j{et,inud},k{az,oupit},l{iv,uka},mlka,olnost,p{ad,is,lout,or,ustit,ykat},razka,s{oudit,tup,un},t{ok,ud},v{aha,eta,olat,racet},znak},f{ina,sajd},h{las,nisko,r{ada,ozit,yzek}},k{ap,enice,lika,no,o{uzlit,vy},r{asa,es,sek,uh},u{pant,rka,sit}},l{ejnina,izovat},m{ak,e{leta,zit},l{adina,ouvat,uva},yl},nehdy,p{a{kovat,sek},erace,i{ce,lost,sovat},o{ra,zice},r{avdu,oti}},r{bital,chestr,gie,l{ice,oj},tel},s{ada,chnout,i{ka,vo},l{ava,epit,nit,ovit},nova,o{ba,lit},palec,t{en,raha,uda,ych},vojit},t{eplit,isk,op,r{hat,lost,ok,uby},vor},v{a{nout,r},es,livnit,oce},xid,zdoba} p{a{c{hatel,ient},douch,horek,kt,l{anda,ec,ivo,uba},m{flet,lsek},n{enka,ika,na,ovat,stvo,tofle},prika,r{keta,odie,ta,uka,yba},s{eka,ivita,telka},t{ent,rona},vouk,z{neht,ourek}},e{cka,dagog,jsek,klo,loton,n{alta,drek,ze},r{iskop,o},strost,t{arda,ice,rolej},vnina,xeso},i{anista,ha,javice,k{le,nik},l{ina,nost,ulka},nzeta,peta,s{atel,tole},tevna,v{nice,ovar}},l{a{centa,kat,men,neta,stika,tit,vidlo,z},e{ch,meno,nta,s,tivo,vel},ivat,n{it,o},o{cha,dina,mba,ut},uk,yn},o{b{avit,yt},c{hod,it,tivec},d{at,cenit,epsat,hled,ivit,klad,manit,nik,oba,pora,raz,stata,vod,zim},ezie,h{anka,nutka,ovor,roma,yb},inta,j{istka,mout},k{azit,les,oj,rok,uta,yn},l{edne,ibek,knout,oha,ynom},m{alu,inout,lka,oc,sta,yslet},n{echat,orka,urost},p{adat,el,isek,lach,rosit,sat,ud},r{adce,ce,od,ucha,yv},s{adit,ed,ila,kok,lanec,oudit,polu,tava,udek,yp},t{ah,kan,lesk,omek,rava,upa,vora},u{kaz,to,zdro},v{aha,idla,lak,oz,rch,stat,yk,zdech},z{drav,emek,natek,or,vat}},r{a{covat,hory,ktika,les,otec,porek,se,vda},incip,kno,o{budit,cento,dej,fese,hra,jekt,lomit,mile,nikat,pad,rok,sba,ton,utek,vaz},s{kavka,ten},u{dkost,t},v{ek,ohory}},s{anec,ovod,truh},tactvo,u{berta,ch,dl,k{avec,lina,rle},lt,mpa,nc,pen,s{a,inka,tina},t{ovat,yka}},y{ramida,sk,tel}} r{a{c{ek,hot},d{iace,nice,on},ft,gby,k{eta,ovina},m{eno,pouch},nde,r{ach,ita},s{ovna,tr},tolest,z{ance,idlo}},e{a{govat,kce},cept,daktor,f{erent,lex},jnok,k{lama,ord,rut,tor},putace,v{ize,ma,olver},zerva},i{skovat,ziko},o{botika,dokmen,hovka,k{le,oko},maneto,p{ovod,ucha},rejs,s{ol,tlina},t{mistr,oped,unda},u{benka,cho,p,ra},v{ina,nice},z{bor,chod,dat,eznat,hodce,inka,jezd,kaz,loha,mar,pad,ruch,sah,tok,um,vod}},u{brika,chadlo,k{avice,opis}},y{b{a,olov},chlost,dlo,padlo,tina,zost}} s{a{dista,hat,ko,m{ec,izdat,ota},nitka,rdinka,sanka,telit,z{ba,enice}},bor,chovat,e{branka,cese,d{adlo,iment,lo},hnat,jmout,k{era,ta,unda,voje},meno,no,rvis,s{adit,hora,kok,lat,tra,uv,ypat},t{ba,ina,kat,nout,rvat},ver,znam},h{oda,rnout},i{fon,lnice,r{ka,otek,up},tuace},k{a{fandr,lisko,nzen,ut},eptik,ica,l{adba,enice,o,uz},o{ba,kan,ro},r{ipta,z},upina,v{ost,rna}},l{a{bika,didlo,nina,st,vnost},e{dovat,pec,va,zina},i{b,na,znice},o{n,upek,vo},u{ch,ha,nce,pka},za},m{aragd,etana,ilstvo,louva,og,r{ad,k,tka},utek,ysl},n{a{d,ha},ob},o{bota,cha,dovka,kol,pka,tva,u{boj,cit,dce,hlas,lad,mrak,prava,sed,tok,viset}},p{a{lovna,sitel},is,lav,o{dek,jenec,lu,nzor,rnost,usta},rcha,ustit},r{a{nda,z},dce,n{a,ec},ovnat,pen,st,ub},t{a{nice,rosta,tika,vba},e{hno,zka},o{dola,lek,pa,rno,upat},r{ach,es,hnout,om,una},u{dna,pnice},vol,yk},u{b{jekt,tropy},char,dost,kno,n{dat,out},r{ikata,ovina}},v{a{h,lstvo},etr,a{tba,zek},i{sle,tek},o{boda,didlo,rka},rab},y{k{avka,ot},n{ek,ovec},p{at,kost},rovost,sel,tost}} t{a{b{letka,ule},houn,j{emno,fun,ga,it,nost},ktika,m{hle,pon},n{covat,ec,ker},peta,venina,zatel},e{chnika,hdy,kutina,lefon,mnota,n{dence,ista,or},p{lota,na,rve},r{apie,moska},xtil},i{cho,skopis,tulek},ka{dlec,nina},l{apka,eskat,u{kot,pa}},mel,o{aleta,p{inka,ol},rzo,u{ha,lec}},r{a{dice,ktor,mp,sa,verza},e{fit,st,zor},h{avina,lina},o{chu,jice,ska,uba},p{ce,itel,kost},u{bec,chlit,hlice,s},vat},u{dy,h{nout,ost},ndra,r{ista,naj},zemsko},v{aroh,orba,r{dost,z}},y{gr,kev}} u{b{o{host,ze},r{at,ousek,us},ytovna},c{ho,tivost},divit,hradit,j{ednat,istit,mout},k{azatel,l{idnit,onit},otvit,rojit},l{i{ce,ta},ovit},myvadlo,n{avit,i{forma,knout}},p{adnout,l{atnit,ynout},outat,ravit},ra{n,zit},s{ednout,ilovat,mrtit,n{adnit,out},oudit,t{lat,rnout}},t{ahovat,kat,lumit,o{nout,penec},rousit},v{alit,o{lnit,zovka}},z{dravit,e{l,nina},lina,nat}} v{a{gon,l{cha,oun},n{a,dal,ilka},r{an,hany,ovat}},c{elku,hod},dova,e{dro,getace,jce,l{bloud,etrh,itel,moc,ryba},nkov,r{anda,ze},s{elka,krze,nice,podu,ta},terina,verka},i{brace,chr,d{eohra,ina,le},la,nice,set,talita,z{e,itka}},jezd,k{lad,us},l{a{jka,k,sec},evo,hkost,iv,novka,oupat},nu{covat,k},o{d{a,ivost,oznak,stvo},j{ensky,na,sko},l{ant,ba,it,no},skovka,z{idlo,ovna}},pravo,r{a{bec,cet,h,ta},ba,cholek,hat,stva,tule},s{adit,t{oupit,up}},tip,y{b{avit,rat},chovat,d{at,ra},fotit,h{ledat,nout,odit,radit,ubit},j{asnit,et,mout},k{lopit,onat},lekat,m{azat,ezit,izet,yslet},n{echat,ikat,utit},p{adat,latit,ravit,ustit},r{azit,ovnat,vat},s{lovit,oko,tavit,unout,ypat},t{asit,esat,ratit},v{inout,olat,rhel},z{dobit,nat}},z{adu,budit,chopit,d{or,uch,ychat},estup,hledem,kaz,lykat,nik,orek,poura,t{ah,ek}}} xylofon z{a{b{rat,ydlet},chovat,d{armo,usit},foukat,h{ltit,odit,rada,ynout},j{atec,et,istit},k{lepat,oupit},lepit,m{ezit,otat,yslet},n{echat,ikat},p{latit,ojit,sat},razit,s{tavit,unout},t{ajit,emnit,knout},ujmout,v{alit,elet,init,olat,rtat},zvonit},b{avit,rusu,udovat,ytek},d{a{leka,rma,tnost},ivo,obit,roj,vih,ymadlo},e{lenina,m{an,ina},ptat,z{adu,dola}},h{atit,l{tnout,uboka},otovit,ruba},im{a,nice},jemnit,k{lamat,oumat,ratka,umavka},l{ato,ehka,o{ba,m,st,zvyk}},m{a{povat,r,tek},i{je,zet},o{cnit,drat},rzlina,utovat},n{a{k,lost,menat},ovu},o{brazit,tavit,u{bek,fale}},p{lodit,omalit,r{ava,ostit,udka,vu}},r{a{da,nit},cadlo,n{itost,o},ovna,ychlit,zavost},t{icha,ratit},ub{ovina,r},v{e{dnout,nku,sela},on,rat,ukovod,yk}} ;;
    ko?(_*)) echo 가격 가끔 가난 가능 가득 가르침 가뭄 가방 가상 가슴 가운데 가을 가이드 가입 가장 가정 가족 가죽 각오 각자 간격 간부 간섭 간장 간접 간판 갈등 갈비 갈색 갈증 감각 감기 감소 감수성 감자 감정 갑자기 강남 강당 강도 강력히 강변 강북 강사 강수량 강아지 강원도 강의 강제 강조 같이 개구리 개나리 개방 개별 개선 개성 개인 객관적 거실 거액 거울 거짓 거품 걱정 건강 건물 건설 건조 건축 걸음 검사 검토 게시판 게임 겨울 견해 결과 결국 결론 결석 결승 결심 결정 결혼 경계 경고 경기 경력 경복궁 경비 경상도 경영 경우 경쟁 경제 경주 경찰 경치 경향 경험 계곡 계단 계란 계산 계속 계약 계절 계층 계획 고객 고구려 고궁 고급 고등학생 고무신 고민 고양이 고장 고전 고집 고춧가루 고통 고향 곡식 골목 골짜기 골프 공간 공개 공격 공군 공급 공기 공동 공무원 공부 공사 공식 공업 공연 공원 공장 공짜 공책 공통 공포 공항 공휴일 과목 과일 과장 과정 과학 관객 관계 관광 관념 관람 관련 관리 관습 관심 관점 관찰 광경 광고 광장 광주 괴로움 굉장히 교과서 교문 교복 교실 교양 교육 교장 교직 교통 교환 교훈 구경 구름 구멍 구별 구분 구석 구성 구속 구역 구입 구청 구체적 국가 국기 국내 국립 국물 국민 국수 국어 국왕 국적 국제 국회 군대 군사 군인 궁극적 권리 권위 권투 귀국 귀신 규정 규칙 균형 그날 그냥 그늘 그러나 그룹 그릇 그림 그제서야 그토록 극복 극히 근거 근교 근래 근로 근무 근본 근원 근육 근처 글씨 글자 금강산 금고 금년 금메달 금액 금연 금요일 금지 긍정적 기간 기관 기념 기능 기독교 기둥 기록 기름 기법 기본 기분 기쁨 기숙사 기술 기억 기업 기온 기운 기원 기적 기준 기침 기혼 기획 긴급 긴장 길이 김밥 김치 김포공항 깍두기 깜빡 깨달음 깨소금 껍질 꼭대기 꽃잎 나들이 나란히 나머지 나물 나침반 나흘 낙엽 난방 날개 날씨 날짜 남녀 남대문 남매 남산 남자 남편 남학생 낭비 낱말 내년 내용 내일 냄비 냄새 냇물 냉동 냉면 냉방 냉장고 넥타이 넷째 노동 노란색 노력 노인 녹음 녹차 녹화 논리 논문 논쟁 놀이 농구 농담 농민 농부 농업 농장 농촌 높이 눈동자 눈물 눈썹 뉴욕 느낌 늑대 능동적 능력 다방 다양성 다음 다이어트 다행 단계 단골 단독 단맛 단순 단어 단위 단점 단체 단추 단편 단풍 달걀 달러 달력 달리 닭고기 담당 담배 담요 담임 답변 답장 당근 당분간 당연히 당장 대규모 대낮 대단히 대답 대도시 대략 대량 대륙 대문 대부분 대신 대응 대장 대전 대접 대중 대책 대출 대충 대통령 대학 대한민국 대합실 대형 덩어리 데이트 도대체 도덕 도둑 도망 도서관 도심 도움 도입 도자기 도저히 도전 도중 도착 독감 독립 독서 독일 독창적 동화책 뒷모습 뒷산 딸아이 마누라 마늘 마당 마라톤 마련 마무리 마사지 마약 마요네즈 마을 마음 마이크 마중 마지막 마찬가지 마찰 마흔 막걸리 막내 막상 만남 만두 만세 만약 만일 만점 만족 만화 많이 말기 말씀 말투 맘대로 망원경 매년 매달 매력 매번 매스컴 매일 매장 맥주 먹이 먼저 먼지 멀리 메일 며느리 며칠 면담 멸치 명단 명령 명예 명의 명절 명칭 명함 모금 모니터 모델 모든 모범 모습 모양 모임 모조리 모집 모퉁이 목걸이 목록 목사 목소리 목숨 목적 목표 몰래 몸매 몸무게 몸살 몸속 몸짓 몸통 몹시 무관심 무궁화 무더위 무덤 무릎 무슨 무엇 무역 무용 무조건 무지개 무척 문구 문득 문법 문서 문제 문학 문화 물가 물건 물결 물고기 물론 물리학 물음 물질 물체 미국 미디어 미사일 미술 미역 미용실 미움 미인 미팅 미혼 민간 민족 민주 믿음 밀가루 밀리미터 밑바닥 바가지 바구니 바나나 바늘 바닥 바닷가 바람 바이러스 바탕 박물관 박사 박수 반대 반드시 반말 반발 반성 반응 반장 반죽 반지 반찬 받침 발가락 발걸음 발견 발달 발레 발목 발바닥 발생 발음 발자국 발전 발톱 발표 밤하늘 밥그릇 밥맛 밥상 밥솥 방금 방면 방문 방바닥 방법 방송 방식 방안 방울 방지 방학 방해 방향 배경 배꼽 배달 배드민턴 백두산 백색 백성 백인 백제 백화점 버릇 버섯 버튼 번개 번역 번지 번호 벌금 벌레 벌써 범위 범인 범죄 법률 법원 법적 법칙 베이징 벨트 변경 변동 변명 변신 변호사 변화 별도 별명 별일 병실 병아리 병원 보관 보너스 보라색 보람 보름 보상 보안 보자기 보장 보전 보존 보통 보편적 보험 복도 복사 복숭아 복습 볶음 본격적 본래 본부 본사 본성 본인 본질 볼펜 봉사 봉지 봉투 부근 부끄러움 부담 부동산 부문 부분 부산 부상 부엌 부인 부작용 부장 부정 부족 부지런히 부친 부탁 부품 부회장 북부 북한 분노 분량 분리 분명 분석 분야 분위기 분필 분홍색 불고기 불과 불교 불꽃 불만 불법 불빛 불안 불이익 불행 브랜드 비극 비난 비닐 비둘기 비디오 비로소 비만 비명 비밀 비바람 비빔밥 비상 비용 비율 비중 비타민 비판 빌딩 빗물 빗방울 빗줄기 빛깔 빨간색 빨래 빨리 사건 사계절 사나이 사냥 사람 사랑 사립 사모님 사물 사방 사상 사생활 사설 사슴 사실 사업 사용 사월 사장 사전 사진 사촌 사춘기 사탕 사투리 사흘 산길 산부인과 산업 산책 살림 살인 살짝 삼계탕 삼국 삼십 삼월 삼촌 상관 상금 상대 상류 상반기 상상 상식 상업 상인 상자 상점 상처 상추 상태 상표 상품 상황 새벽 색깔 색연필 생각 생명 생물 생방송 생산 생선 생신 생일 생활 서랍 서른 서명 서민 서비스 서양 서울 서적 서점 서쪽 서클 석사 석유 선거 선물 선배 선생 선수 선원 선장 선전 선택 선풍기 설거지 설날 설렁탕 설명 설문 설사 설악산 설치 설탕 섭씨 성공 성당 성명 성별 성인 성장 성적 성질 성함 세금 세미나 세상 세월 세종대왕 세탁 센터 센티미터 셋째 소규모 소극적 소금 소나기 소년 소득 소망 소문 소설 소속 소아과 소용 소원 소음 소중히 소지품 소질 소풍 소형 속담 속도 속옷 손가락 손길 손녀 손님 손등 손목 손뼉 손실 손질 손톱 손해 솔직히 솜씨 송아지 송이 송편 쇠고기 쇼핑 수건 수년 수단 수돗물 수동적 수면 수명 수박 수상 수석 수술 수시로 수업 수염 수영 수입 수준 수집 수출 수컷 수필 수학 수험생 수화기 숙녀 숙소 숙제 순간 순서 순수 순식간 순위 숟가락 술병 술집 숫자 스님 스물 스스로 스승 스웨터 스위치 스케이트 스튜디오 스트레스 스포츠 슬쩍 슬픔 습관 습기 승객 승리 승부 승용차 승진 시각 시간 시골 시금치 시나리오 시댁 시리즈 시멘트 시민 시부모 시선 시설 시스템 시아버지 시어머니 시월 시인 시일 시작 시장 시절 시점 시중 시즌 시집 시청 시합 시험 식구 식기 식당 식량 식료품 식물 식빵 식사 식생활 식초 식탁 식품 신고 신규 신념 신문 신발 신비 신사 신세 신용 신제품 신청 신체 신화 실감 실내 실력 실례 실망 실수 실습 실시 실장 실정 실질적 실천 실체 실컷 실태 실패 실험 실현 심리 심부름 심사 심장 심정 심판 쌍둥이 씨름 씨앗 아가씨 아나운서 아드님 아들 아쉬움 아스팔트 아시아 아울러 아저씨 아줌마 아직 아침 아파트 아프리카 아픔 아홉 아흔 악기 악몽 악수 안개 안경 안과 안내 안녕 안동 안방 안부 안주 알루미늄 알코올 암시 암컷 압력 앞날 앞문 애인 애정 액수 앨범 야간 야단 야옹 약간 약국 약속 약수 약점 약품 약혼녀 양념 양력 양말 양배추 양주 양파 어둠 어려움 어른 어젯밤 어쨌든 어쩌다가 어쩐지 언니 언덕 언론 언어 얼굴 얼른 얼음 얼핏 엄마 업무 업종 업체 엉덩이 엉망 엉터리 엊그제 에너지 에어컨 엔진 여건 여고생 여관 여군 여권 여대생 여덟 여동생 여든 여론 여름 여섯 여성 여왕 여인 여전히 여직원 여학생 여행 역사 역시 역할 연결 연구 연극 연기 연락 연설 연세 연속 연습 연애 연예인 연인 연장 연주 연출 연필 연합 연휴 열기 열매 열쇠 열심히 열정 열차 열흘 염려 엽서 영국 영남 영상 영양 영역 영웅 영원히 영하 영향 영혼 영화 옆구리 옆방 옆집 예감 예금 예방 예산 예상 예선 예술 예습 예식장 예약 예전 예절 예정 예컨대 옛날 오늘 오락 오랫동안 오렌지 오로지 오른발 오븐 오십 오염 오월 오전 오직 오징어 오페라 오피스텔 오히려 옥상 옥수수 온갖 온라인 온몸 온종일 온통 올가을 올림픽 올해 옷차림 와이셔츠 와인 완성 완전 왕비 왕자 왜냐하면 왠지 외갓집 외국 외로움 외삼촌 외출 외침 외할머니 왼발 왼손 왼쪽 요금 요일 요즘 요청 용기 용서 용어 우산 우선 우승 우연히 우정 우체국 우편 운동 운명 운반 운전 운행 울산 울음 움직임 웃어른 웃음 워낙 원고 원래 원서 원숭이 원인 원장 원피스 월급 월드컵 월세 월요일 웨이터 위반 위법 위성 위원 위험 위협 윗사람 유난히 유럽 유명 유물 유산 유적 유치원 유학 유행 유형 육군 육상 육십 육체 은행 음력 음료 음반 음성 음식 음악 음주 의견 의논 의문 의복 의식 의심 의외로 의욕 의원 의학 이것 이곳 이념 이놈 이달 이대로 이동 이렇게 이력서 이론적 이름 이민 이발소 이별 이불 이빨 이상 이성 이슬 이야기 이용 이웃 이월 이윽고 이익 이전 이중 이튿날 이틀 이혼 인간 인격 인공 인구 인근 인기 인도 인류 인물 인생 인쇄 인연 인원 인재 인종 인천 인체 인터넷 인하 인형 일곱 일기 일단 일대 일등 일반 일본 일부 일상 일생 일손 일요일 일월 일정 일종 일주일 일찍 일체 일치 일행 일회용 임금 임무 입대 입력 입맛 입사 입술 입시 입원 입장 입학 자가용 자격 자극 자동 자랑 자부심 자식 자신 자연 자원 자율 자전거 자정 자존심 자판 작가 작년 작성 작업 작용 작은딸 작품 잔디 잔뜩 잔치 잘못 잠깐 잠수함 잠시 잠옷 잠자리 잡지 장관 장군 장기간 장래 장례 장르 장마 장면 장모 장미 장비 장사 장소 장식 장애인 장인 장점 장차 장학금 재능 재빨리 재산 재생 재작년 재정 재채기 재판 재학 재활용 저것 저고리 저곳 저녁 저런 저렇게 저번 저울 저절로 저축 적극 적당히 적성 적용 적응 전개 전공 전기 전달 전라도 전망 전문 전반 전부 전세 전시 전용 전자 전쟁 전주 전철 전체 전통 전혀 전후 절대 절망 절반 절약 절차 점검 점수 점심 점원 점점 점차 접근 접시 접촉 젓가락 정거장 정도 정류장 정리 정말 정면 정문 정반대 정보 정부 정비 정상 정성 정오 정원 정장 정지 정치 정확히 제공 제과점 제대로 제목 제발 제법 제삿날 제안 제일 제작 제주도 제출 제품 제한 조각 조건 조금 조깅 조명 조미료 조상 조선 조용히 조절 조정 조직 존댓말 존재 졸업 졸음 종교 종로 종류 종소리 종업원 종종 종합 좌석 죄인 주관적 주름 주말 주머니 주먹 주문 주민 주방 주변 주식 주인 주일 주장 주전자 주택 준비 줄거리 줄기 줄무늬 중간 중계방송 중국 중년 중단 중독 중반 중부 중세 중소기업 중순 중앙 중요 중학교 즉석 즉시 즐거움 증가 증거 증권 증상 증세 지각 지갑 지경 지극히 지금 지급 지능 지름길 지리산 지방 지붕 지식 지역 지우개 지원 지적 지점 지진 지출 직선 직업 직원 직장 진급 진동 진로 진료 진리 진짜 진찰 진출 진통 진행 질문 질병 질서 짐작 집단 집안 집중 짜증 찌꺼기 차남 차라리 차량 차림 차별 차선 차츰 착각 찬물 찬성 참가 참기름 참새 참석 참여 참외 참조 찻잔 창가 창고 창구 창문 창밖 창작 창조 채널 채점 책가방 책방 책상 책임 챔피언 처벌 처음 천국 천둥 천장 천재 천천히 철도 철저히 철학 첫날 첫째 청년 청바지 청소 청춘 체계 체력 체온 체육 체중 체험 초등학생 초반 초밥 초상화 초순 초여름 초원 초저녁 초점 초청 초콜릿 촛불 총각 총리 총장 촬영 최근 최상 최선 최신 최악 최종 추석 추억 추진 추천 추측 축구 축소 축제 축하 출근 출발 출산 출신 출연 출입 출장 출판 충격 충고 충돌 충분히 충청도 취업 취직 취향 치약 친구 친척 칠십 칠월 칠판 침대 침묵 침실 칫솔 칭찬 카메라 카운터 칼국수 캐릭터 캠퍼스 캠페인 커튼 컨디션 컬러 컴퓨터 코끼리 코미디 콘서트 콜라 콤플렉스 콩나물 쾌감 쿠데타 크림 큰길 큰딸 큰소리 큰아들 큰어머니 큰일 큰절 클래식 클럽 킬로 타입 타자기 탁구 탁자 탄생 태권도 태양 태풍 택시 탤런트 터널 터미널 테니스 테스트 테이블 텔레비전 토론 토마토 토요일 통계 통과 통로 통신 통역 통일 통장 통제 통증 통합 통화 퇴근 퇴원 퇴직금 튀김 트럭 특급 특별 특성 특수 특징 특히 튼튼히 티셔츠 파란색 파일 파출소 판결 판단 판매 판사 팔십 팔월 팝송 패션 팩스 팩시밀리 팬티 퍼센트 페인트 편견 편의 편지 편히 평가 평균 평생 평소 평양 평일 평화 포스터 포인트 포장 포함 표면 표정 표준 표현 품목 품질 풍경 풍속 풍습 프랑스 프린터 플라스틱 피곤 피망 피아노 필름 필수 필요 필자 필통 핑계 하느님 하늘 하드웨어 하룻밤 하반기 하숙집 하순 하여튼 하지만 하천 하품 하필 학과 학교 학급 학기 학년 학력 학번 학부모 학비 학생 학술 학습 학용품 학원 학위 학자 학점 한계 한글 한꺼번에 한낮 한눈 한동안 한때 한라산 한마디 한문 한번 한복 한식 한여름 한쪽 할머니 할아버지 할인 함께 함부로 합격 합리적 항공 항구 항상 항의 해결 해군 해답 해당 해물 해석 해설 해수욕장 해안 핵심 핸드백 햄버거 햇볕 햇살 행동 행복 행사 행운 행위 향기 향상 향수 허락 허용 헬기 현관 현금 현대 현상 현실 현장 현재 현지 혈액 협력 형부 형사 형수 형식 형제 형태 형편 혜택 호기심 호남 호랑이 호박 호텔 호흡 혹시 홀로 홈페이지 홍보 홍수 홍차 화면 화분 화살 화요일 화장 화학 확보 확인 확장 확정 환갑 환경 환영 환율 환자 활기 활동 활발히 활용 활짝 회견 회관 회복 회색 회원 회장 회전 횟수 횡단보도 효율적 후반 후춧가루 훈련 훨씬 휴식 휴일 흉내 흐름 흑백 흑인 흔적 흔히 흥미 흥분 희곡 희망 희생 흰색 힘껏 ;;
    ja?(_*)) echo あいこくしん あいさつ あいだ あおぞら あかちゃん あきる あけがた あける あこがれる あさい あさひ あしあと あじわう あずかる あずき あそぶ あたえる あたためる あたりまえ あたる あつい あつかう あっしゅく あつまり あつめる あてな あてはまる あひる あぶら あぶる あふれる あまい あまど あまやかす あまり あみもの あめりか あやまる あゆむ あらいぐま あらし あらすじ あらためる あらゆる あらわす ありがとう あわせる あわてる あんい あんがい あんこ あんぜん あんてい あんない あんまり いいだす いおん いがい いがく いきおい いきなり いきもの いきる いくじ いくぶん いけばな いけん いこう いこく いこつ いさましい いさん いしき いじゅう いじょう いじわる いずみ いずれ いせい いせえび いせかい いせき いぜん いそうろう いそがしい いだい いだく いたずら いたみ いたりあ いちおう いちじ いちど いちば いちぶ いちりゅう いつか いっしゅん いっせい いっそう いったん いっち いってい いっぽう いてざ いてん いどう いとこ いない いなか いねむり いのち いのる いはつ いばる いはん いびき いひん いふく いへん いほう いみん いもうと いもたれ いもり いやがる いやす いよかん いよく いらい いらすと いりぐち いりょう いれい いれもの いれる いろえんぴつ いわい いわう いわかん いわば いわゆる いんげんまめ いんさつ いんしょう いんよう うえき うえる うおざ うがい うかぶ うかべる うきわ うくらいな うくれれ うけたまわる うけつけ うけとる うけもつ うける うごかす うごく うこん うさぎ うしなう うしろがみ うすい うすぎ うすぐらい うすめる うせつ うちあわせ うちがわ うちき うちゅう うっかり うつくしい うったえる うつる うどん うなぎ うなじ うなずく うなる うねる うのう うぶげ うぶごえ うまれる うめる うもう うやまう うよく うらがえす うらぐち うらない うりあげ うりきれ うるさい うれしい うれゆき うれる うろこ うわき うわさ うんこう うんちん うんてん うんどう えいえん えいが えいきょう えいご えいせい えいぶん えいよう えいわ えおり えがお えがく えきたい えくせる えしゃく えすて えつらん えのぐ えほうまき えほん えまき えもじ えもの えらい えらぶ えりあ えんえん えんかい えんぎ えんげき えんしゅう えんぜつ えんそく えんちょう えんとつ おいかける おいこす おいしい おいつく おうえん おうさま おうじ おうせつ おうたい おうふく おうべい おうよう おえる おおい おおう おおどおり おおや おおよそ おかえり おかず おがむ おかわり おぎなう おきる おくさま おくじょう おくりがな おくる おくれる おこす おこなう おこる おさえる おさない おさめる おしいれ おしえる おじぎ おじさん おしゃれ おそらく おそわる おたがい おたく おだやか おちつく おっと おつり おでかけ おとしもの おとなしい おどり おどろかす おばさん おまいり おめでとう おもいで おもう おもたい おもちゃ おやつ おやゆび およぼす おらんだ おろす おんがく おんけい おんしゃ おんせん おんだん おんちゅう おんどけい かあつ かいが がいき がいけん がいこう かいさつ かいしゃ かいすいよく かいぜん かいぞうど かいつう かいてん かいとう かいふく がいへき かいほう かいよう がいらい かいわ かえる かおり かかえる かがく かがし かがみ かくご かくとく かざる がぞう かたい かたち がちょう がっきゅう がっこう がっさん がっしょう かなざわし かのう がはく かぶか かほう かほご かまう かまぼこ かめれおん かゆい かようび からい かるい かろう かわく かわら がんか かんけい かんこう かんしゃ かんそう かんたん かんち がんばる きあい きあつ きいろ ぎいん きうい きうん きえる きおう きおく きおち きおん きかい きかく きかんしゃ ききて きくばり きくらげ きけんせい きこう きこえる きこく きさい きさく きさま きさらぎ ぎじかがく ぎしき ぎじたいけん ぎじにってい ぎじゅつしゃ きすう きせい きせき きせつ きそう きぞく きぞん きたえる きちょう きつえん ぎっちり きつつき きつね きてい きどう きどく きない きなが きなこ きぬごし きねん きのう きのした きはく きびしい きひん きふく きぶん きぼう きほん きまる きみつ きむずかしい きめる きもだめし きもち きもの きゃく きやく ぎゅうにく きよう きょうりゅう きらい きらく きりん きれい きれつ きろく ぎろん きわめる ぎんいろ きんかくじ きんじょ きんようび ぐあい くいず くうかん くうき くうぐん くうこう ぐうせい くうそう ぐうたら くうふく くうぼ くかん くきょう くげん ぐこう くさい くさき くさばな くさる くしゃみ くしょう くすのき くすりゆび くせげ くせん ぐたいてき くださる くたびれる くちこみ くちさき くつした ぐっすり くつろぐ くとうてん くどく くなん くねくね くのう くふう くみあわせ くみたてる くめる くやくしょ くらす くらべる くるま くれる くろう くわしい ぐんかん ぐんしょく ぐんたい ぐんて けあな けいかく けいけん けいこ けいさつ げいじゅつ けいたい げいのうじん けいれき けいろ けおとす けおりもの げきか げきげん げきだん げきちん げきとつ げきは げきやく げこう げこくじょう げざい けさき げざん けしき けしごむ けしょう げすと けたば けちゃっぷ けちらす けつあつ けつい けつえき けっこん けつじょ けっせき けってい けつまつ げつようび げつれい けつろん げどく けとばす けとる けなげ けなす けなみ けぬき げねつ けねん けはい げひん けぶかい げぼく けまり けみかる けむし けむり けもの けらい けろけろ けわしい けんい けんえつ けんお けんか げんき けんげん けんこう けんさく けんしゅう けんすう げんそう けんちく けんてい けんとう けんない けんにん げんぶつ けんま けんみん けんめい けんらん けんり こあくま こいぬ こいびと ごうい こうえん こうおん こうかん ごうきゅう ごうけい こうこう こうさい こうじ こうすい ごうせい こうそく こうたい こうちゃ こうつう こうてい こうどう こうない こうはい ごうほう ごうまん こうもく こうりつ こえる こおり ごかい ごがつ ごかん こくご こくさい こくとう こくない こくはく こぐま こけい こける ここのか こころ こさめ こしつ こすう こせい こせき こぜん こそだて こたい こたえる こたつ こちょう こっか こつこつ こつばん こつぶ こてい こてん ことがら ことし ことば ことり こなごな こねこね このまま このみ このよ ごはん こひつじ こふう こふん こぼれる ごまあぶら こまかい ごますり こまつな こまる こむぎこ こもじ こもち こもの こもん こやく こやま こゆう こゆび こよい こよう こりる これくしょん ころっけ こわもて こわれる こんいん こんかい こんき こんしゅう こんすい こんだて こんとん こんなん こんびに こんぽん こんまけ こんや こんれい こんわく ざいえき さいかい さいきん ざいげん ざいこ さいしょ さいせい ざいたく ざいちゅう さいてき ざいりょう さうな さかいし さがす さかな さかみち さがる さぎょう さくし さくひん さくら さこく さこつ さずかる ざせき さたん さつえい ざつおん ざっか ざつがく さっきょく ざっし さつじん ざっそう さつたば さつまいも さてい さといも さとう さとおや さとし さとる さのう さばく さびしい さべつ さほう さほど さます さみしい さみだれ さむけ さめる さやえんどう さゆう さよう さよく さらだ ざるそば さわやか さわる さんいん さんか さんきゃく さんこう さんさい ざんしょ さんすう さんせい さんそ さんち さんま さんみ さんらん しあい しあげ しあさって しあわせ しいく しいん しうち しえい しおけ しかい しかく じかん しごと しすう じだい したうけ したぎ したて したみ しちょう しちりん しっかり しつじ しつもん してい してき してつ じてん じどう しなぎれ しなもの しなん しねま しねん しのぐ しのぶ しはい しばかり しはつ しはらい しはん しひょう しふく じぶん しへい しほう しほん しまう しまる しみん しむける じむしょ しめい しめる しもん しゃいん しゃうん しゃおん じゃがいも しやくしょ しゃくほう しゃけん しゃこ しゃざい しゃしん しゃせん しゃそう しゃたい しゃちょう しゃっきん じゃま しゃりん しゃれい じゆう じゅうしょ しゅくはく じゅしん しゅっせき しゅみ しゅらば じゅんばん しょうかい しょくたく しょっけん しょどう しょもつ しらせる しらべる しんか しんこう じんじゃ しんせいじ しんちく しんりん すあげ すあし すあな ずあん すいえい すいか すいとう ずいぶん すいようび すうがく すうじつ すうせん すおどり すきま すくう すくない すける すごい すこし ずさん すずしい すすむ すすめる すっかり ずっしり ずっと すてき すてる すねる すのこ すはだ すばらしい ずひょう ずぶぬれ すぶり すふれ すべて すべる ずほう すぼん すまい すめし すもう すやき すらすら するめ すれちがう すろっと すわる すんぜん すんぽう せあぶら せいかつ せいげん せいじ せいよう せおう せかいかん せきにん せきむ せきゆ せきらんうん せけん せこう せすじ せたい せたけ せっかく せっきゃく ぜっく せっけん せっこつ せっさたくま せつぞく せつだん せつでん せっぱん せつび せつぶん せつめい せつりつ せなか せのび せはば せびろ せぼね せまい せまる せめる せもたれ せりふ ぜんあく せんい せんえい せんか せんきょ せんく せんげん ぜんご せんさい せんしゅ せんすい せんせい せんぞ せんたく せんちょう せんてい せんとう せんぬき せんねん せんぱい ぜんぶ ぜんぽう せんむ せんめんじょ せんもん せんやく せんゆう せんよう ぜんら ぜんりゃく せんれい せんろ そあく そいとげる そいね そうがんきょう そうき そうご そうしん そうだん そうなん そうび そうめん そうり そえもの そえん そがい そげき そこう そこそこ そざい そしな そせい そせん そそぐ そだてる そつう そつえん そっかん そつぎょう そっけつ そっこう そっせん そっと そとがわ そとづら そなえる そなた そふぼ そぼく そぼろ そまつ そまる そむく そむりえ そめる そもそも そよかぜ そらまめ そろう そんかい そんけい そんざい そんしつ そんぞく そんちょう ぞんび ぞんぶん そんみん たあい たいいん たいうん たいえき たいおう だいがく たいき たいぐう たいけん たいこ たいざい だいじょうぶ だいすき たいせつ たいそう だいたい たいちょう たいてい だいどころ たいない たいねつ たいのう たいはん だいひょう たいふう たいへん たいほ たいまつばな たいみんぐ たいむ たいめん たいやき たいよう たいら たいりょく たいる たいわん たうえ たえる たおす たおる たおれる たかい たかね たきび たくさん たこく たこやき たさい たしざん だじゃれ たすける たずさわる たそがれ たたかう たたく ただしい たたみ たちばな だっかい だっきゃく だっこ だっしゅつ だったい たてる たとえる たなばた たにん たぬき たのしみ たはつ たぶん たべる たぼう たまご たまる だむる ためいき ためす ためる たもつ たやすい たよる たらす たりきほんがん たりょう たりる たると たれる たれんと たろっと たわむれる だんあつ たんい たんおん たんか たんき たんけん たんご たんさん たんじょうび だんせい たんそく たんたい だんち たんてい たんとう だんな たんにん だんねつ たんのう たんぴん だんぼう たんまつ たんめい だんれつ だんろ だんわ ちあい ちあん ちいき ちいさい ちえん ちかい ちから ちきゅう ちきん ちけいず ちけん ちこく ちさい ちしき ちしりょう ちせい ちそう ちたい ちたん ちちおや ちつじょ ちてき ちてん ちぬき ちぬり ちのう ちひょう ちへいせん ちほう ちまた ちみつ ちみどろ ちめいど ちゃんこなべ ちゅうい ちゆりょく ちょうし ちょさくけん ちらし ちらみ ちりがみ ちりょう ちるど ちわわ ちんたい ちんもく ついか ついたち つうか つうじょう つうはん つうわ つかう つかれる つくね つくる つけね つける つごう つたえる つづく つつじ つつむ つとめる つながる つなみ つねづね つのる つぶす つまらない つまる つみき つめたい つもり つもる つよい つるぼ つるみく つわもの つわり てあし てあて てあみ ていおん ていか ていき ていけい ていこく ていさつ ていし ていせい ていたい ていど ていねい ていひょう ていへん ていぼう てうち ておくれ てきとう てくび でこぼこ てさぎょう てさげ てすり てそう てちがい てちょう てつがく てつづき でっぱ てつぼう てつや でぬかえ てぬき てぬぐい てのひら てはい てぶくろ てふだ てほどき てほん てまえ てまきずし てみじか てみやげ てらす てれび てわけ てわたし でんあつ てんいん てんかい てんき てんぐ てんけん てんごく てんさい てんし てんすう でんち てんてき てんとう てんない てんぷら てんぼうだい てんめつ てんらんかい でんりょく でんわ どあい といれ どうかん とうきゅう どうぐ とうし とうむぎ とおい とおか とおく とおす とおる とかい とかす ときおり ときどき とくい とくしゅう とくてん とくに とくべつ とけい とける とこや とさか としょかん とそう とたん とちゅう とっきゅう とっくん とつぜん とつにゅう とどける ととのえる とない となえる となり とのさま とばす どぶがわ とほう とまる とめる ともだち ともる どようび とらえる とんかつ どんぶり ないかく ないこう ないしょ ないす ないせん ないそう なおす ながい なくす なげる なこうど なさけ なたでここ なっとう なつやすみ ななおし なにごと なにもの なにわ なのか なふだ なまいき なまえ なまみ なみだ なめらか なめる なやむ ならう ならび ならぶ なれる なわとび なわばり にあう にいがた にうけ におい にかい にがて にきび にくしみ にくまん にげる にさんかたんそ にしき にせもの にちじょう にちようび にっか にっき にっけい にっこう にっさん にっしょく にっすう にっせき にってい になう にほん にまめ にもつ にやり にゅういん にりんしゃ にわとり にんい にんか にんき にんげん にんしき にんずう にんそう にんたい にんち にんてい にんにく にんぷ にんまり にんむ にんめい にんよう ぬいくぎ ぬかす ぬぐいとる ぬぐう ぬくもり ぬすむ ぬまえび ぬめり ぬらす ぬんちゃく ねあげ ねいき ねいる ねいろ ねぐせ ねくたい ねくら ねこぜ ねこむ ねさげ ねすごす ねそべる ねだん ねつい ねっしん ねつぞう ねったいぎょ ねぶそく ねふだ ねぼう ねほりはほり ねまき ねまわし ねみみ ねむい ねむたい ねもと ねらう ねわざ ねんいり ねんおし ねんかん ねんきん ねんぐ ねんざ ねんし ねんちゃく ねんど ねんぴ ねんぶつ ねんまつ ねんりょう ねんれい のいず のおづま のがす のきなみ のこぎり のこす のこる のせる のぞく のぞむ のたまう のちほど のっく のばす のはら のべる のぼる のみもの のやま のらいぬ のらねこ のりもの のりゆき のれん のんき ばあい はあく ばあさん ばいか ばいく はいけん はいご はいしん はいすい はいせん はいそう はいち ばいばい はいれつ はえる はおる はかい ばかり はかる はくしゅ はけん はこぶ はさみ はさん はしご ばしょ はしる はせる ぱそこん はそん はたん はちみつ はつおん はっかく はづき はっきり はっくつ はっけん はっこう はっさん はっしん はったつ はっちゅう はってん はっぴょう はっぽう はなす はなび はにかむ はぶらし はみがき はむかう はめつ はやい はやし はらう はろうぃん はわい はんい はんえい はんおん はんかく はんきょう ばんぐみ はんこ はんしゃ はんすう はんだん ぱんち ぱんつ はんてい はんとし はんのう はんぱ はんぶん はんぺん はんぼうき はんめい はんらん はんろん ひいき ひうん ひえる ひかく ひかり ひかる ひかん ひくい ひけつ ひこうき ひこく ひさい ひさしぶり ひさん びじゅつかん ひしょ ひそか ひそむ ひたむき ひだり ひたる ひつぎ ひっこし ひっし ひつじゅひん ひっす ひつぜん ぴったり ぴっちり ひつよう ひてい ひとごみ ひなまつり ひなん ひねる ひはん ひびく ひひょう ひほう ひまわり ひまん ひみつ ひめい ひめじし ひやけ ひやす ひよう びょうき ひらがな ひらく ひりつ ひりょう ひるま ひるやすみ ひれい ひろい ひろう ひろき ひろゆき ひんかく ひんけつ ひんこん ひんしゅ ひんそう ぴんち ひんぱん びんぼう ふあん ふいうち ふうけい ふうせん ぷうたろう ふうとう ふうふ ふえる ふおん ふかい ふきん ふくざつ ふくぶくろ ふこう ふさい ふしぎ ふじみ ふすま ふせい ふせぐ ふそく ぶたにく ふたん ふちょう ふつう ふつか ふっかつ ふっき ふっこく ぶどう ふとる ふとん ふのう ふはい ふひょう ふへん ふまん ふみん ふめつ ふめん ふよう ふりこ ふりる ふるい ふんいき ぶんがく ぶんぐ ふんしつ ぶんせき ふんそう ぶんぽう へいあん へいおん へいがい へいき へいげん へいこう へいさ へいしゃ へいせつ へいそ へいたく へいてん へいねつ へいわ へきが へこむ べにいろ べにしょうが へらす へんかん べんきょう べんごし へんさい へんたい べんり ほあん ほいく ぼうぎょ ほうこく ほうそう ほうほう ほうもん ほうりつ ほえる ほおん ほかん ほきょう ぼきん ほくろ ほけつ ほけん ほこう ほこる ほしい ほしつ ほしゅ ほしょう ほせい ほそい ほそく ほたて ほたる ぽちぶくろ ほっきょく ほっさ ほったん ほとんど ほめる ほんい ほんき ほんけ ほんしつ ほんやく まいにち まかい まかせる まがる まける まこと まさつ まじめ ますく まぜる まつり まとめ まなぶ まぬけ まねく まほう まもる まゆげ まよう まろやか まわす まわり まわる まんが まんきつ まんぞく まんなか みいら みうち みえる みがく みかた みかん みけん みこん みじかい みすい みすえる みせる みっか みつかる みつける みてい みとめる みなと みなみかさい みねらる みのう みのがす みほん みもと みやげ みらい みりょく みわく みんか みんぞく むいか むえき むえん むかい むかう むかえ むかし むぎちゃ むける むげん むさぼる むしあつい むしば むじゅん むしろ むすう むすこ むすぶ むすめ むせる むせん むちゅう むなしい むのう むやみ むよう むらさき むりょう むろん めいあん めいうん めいえん めいかく めいきょく めいさい めいし めいそう めいぶつ めいれい めいわく めぐまれる めざす めした めずらしい めだつ めまい めやす めんきょ めんせき めんどう もうしあげる もうどうけん もえる もくし もくてき もくようび もちろん もどる もらう もんく もんだい やおや やける やさい やさしい やすい やすたろう やすみ やせる やそう やたい やちん やっと やっぱり やぶる やめる ややこしい やよい やわらかい ゆうき ゆうびんきょく ゆうべ ゆうめい ゆけつ ゆしゅつ ゆせん ゆそう ゆたか ゆちゃく ゆでる ゆにゅう ゆびわ ゆらい ゆれる ようい ようか ようきゅう ようじ ようす ようちえん よかぜ よかん よきん よくせい よくぼう よけい よごれる よさん よしゅう よそう よそく よっか よてい よどがわく よねつ よやく よゆう よろこぶ よろしい らいう らくがき らくご らくさつ らくだ らしんばん らせん らぞく らたい らっか られつ りえき りかい りきさく りきせつ りくぐん りくつ りけん りこう りせい りそう りそく りてん りねん りゆう りゅうがく りよう りょうり りょかん りょくちゃ りょこう りりく りれき りろん りんご るいけい るいさい るいじ るいせき るすばん るりがわら れいかん れいぎ れいせい れいぞうこ れいとう れいぼう れきし れきだい れんあい れんけい れんこん れんさい れんしゅう れんぞく れんらく ろうか ろうご ろうじん ろうそく ろくが ろこつ ろじうら ろしゅつ ろせん ろてん ろめん ろれつ ろんぎ ろんぱ ろんぶん ろんり わかす わかめ わかやま わかれる わしつ わじまし わすれもの わらう われる ;;
    *)       echo a{b{andon,ility,le,o{ut,ve},s{ent,orb,tract,urd},use},c{c{ess,ident,ount,use},hieve,id,oustic,quire,ross,t{,ion,or,ress,ual}},d{apt,d{,ict,ress},just,mit,ult,v{ance,ice}},erobic,f{f{air,ord},raid},g{ain,e{,nt},ree},head,i{m,r{,port},sle},l{arm,bum,cohol,ert,ien,l{,ey,ow},most,one,pha,ready,so,ter,ways},m{a{teur,zing},o{ng,unt},used},n{alyst,c{hor,ient},g{er,le,ry},imal,kle,n{ounce,ual},other,swer,t{enna,ique},xiety,y},p{art,ology,p{ear,le,rove},ril},r{c{h,tic},e{a,na},gue,m{,ed,or,y},ound,r{ange,est,ive,ow},t{,efact,ist,work}},s{k,pect,s{ault,et,ist,ume},thma},t{hlete,om,t{ack,end,itude,ract}},u{ction,dit,gust,nt,t{hor,o,umn}},v{erage,o{cado,id}},w{a{ke,re,y},esome,ful,kward},xis} b{a{by,c{helor,on},dge,g,l{ance,cony,l},mboo,n{ana,ner},r{,ely,gain,rel},s{e,ic,ket},ttle},e{a{ch,n,uty},c{ause,ome},ef,fore,gin,h{ave,ind},l{ieve,ow,t},n{ch,efit},st,t{ray,ter,ween},yond},i{cycle,d,ke,nd,ology,r{d,th},tter},l{a{ck,de,me,nket,st},e{ak,ss},ind,o{od,ssom,use},u{e,r,sh}},o{a{rd,t},dy,il,mb,n{e,us},o{k,st},r{der,ing,row},ss,ttom,unce,x,y},r{a{cket,in,nd,ss,ve},e{ad,eze},i{ck,dge,ef,ght,ng,sk},o{ccoli,ken,nze,om,ther,wn},ush},u{bble,d{dy,get},ffalo,ild,l{b,k,let},n{dle,ker},r{den,ger,st},s{,iness,y},tter,yer,zz}} c{a{b{bage,in,le},ctus,ge,ke,l{l,m},m{era,p},n{,al,cel,dy,non,oe,vas,yon},p{able,ital,tain},r{,bon,d,go,pet,ry,t},s{e,h,ino,tle,ual},t{,alog,ch,egory,tle},u{ght,se,tion},ve},e{iling,lery,ment,n{sus,tury},r{eal,tain}},h{a{ir,lk,mpion,nge,os,pter,rge,se,t},e{ap,ck,ese,f,rry,st},i{cken,ef,ld,mney},o{ice,ose},ronic,u{ckle,nk,rn}},i{gar,nnamon,rcle,t{izen,y},vil},l{a{im,p,rify,w,y},e{an,rk,ver},i{ck,ent,ff,mb,nic,p},o{ck,g,se,th,ud,wn},u{b,mp,ster,tch}},o{a{ch,st},conut,de,ffee,i{l,n},l{lect,or,umn},m{bine,e,fort,ic,mon,pany},n{cert,duct,firm,gress,nect,sider,trol,vince},o{k,l},p{per,y},r{al,e,n,rect},st,tton,u{ch,ntry,ple,rse,sin},ver,yote},r{a{ck,dle,ft,m,ne,sh,ter,wl,zy},e{am,dit,ek,w},i{cket,me,sp,tic},o{p,ss,uch,wd},u{cial,el,ise,mble,nch,sh},y{,stal}},u{be,lture,p{,board},r{ious,rent,tain,ve},s{hion,tom},te},ycle} d{a{d,m{age,p},n{ce,ger},ring,sh,ughter,wn,y},e{al,b{ate,ris},c{ade,ember,ide,line,orate,rease},er,f{ense,ine,y},gree,l{ay,iver},m{and,ise},n{ial,tist,y},p{art,end,osit,th,uty},rive,s{cribe,ert,ign,k,pair,troy},t{ail,ect},v{elop,ice,ote}},i{a{gram,l,mond,ry},ce,e{sel,t},ffer,g{ital,nity},lemma,n{ner,osaur},r{ect,t},s{agree,cover,ease,h,miss,order,play,tance},v{ert,ide,orce},zzy},o{c{tor,ument},g,l{l,phin},main,n{ate,key,or},or,se,uble,ve},r{a{ft,gon,ma,stic,w},e{am,ss},i{ft,ll,nk,p,ve},op,um,y},u{ck,mb,ne,ring,st,t{ch,y}},warf,ynamic} e{a{g{er,le},r{ly,n,th},s{ily,t,y}},c{ho,o{logy,nomy}},d{ge,it,ucate},ffort,gg,i{ght,ther},l{bow,der,e{ctric,gant,ment,phant,vator},ite,se},m{b{ark,ody,race},erge,otion,p{loy,ower,ty}},n{a{ble,ct},d{,less,orse},e{my,rgy},force,g{age,ine},hance,joy,list,ough,r{ich,oll},sure,t{er,ire,ry},velope},pisode,qu{al,ip},r{a{,se},o{de,sion},ror,upt},s{cape,s{ay,ence},tate},t{ernal,hics},v{i{dence,l},o{ke,lve}},x{a{ct,mple},c{ess,hange,ite,lude,use},e{cute,rcise},h{aust,ibit},i{le,st,t},otic,p{and,ect,ire,lain,ose,ress},t{end,ra}},ye{,brow}} f{a{bric,c{e,ulty},de,i{nt,th},l{l,se},m{e,ily,ous},n{,cy,tasy},rm,shion,t{,al,her,igue},ult,vorite},e{ature,bruary,deral,e{,d,l},male,nce,stival,tch,ver,w},i{ber,ction,eld,gure,l{e,m,ter},n{al,d,e,ger,ish},r{e,m,st},s{cal,h},t{,ness},x},l{a{g,me,sh,t,vor},ee,i{ght,p},o{at,ck,or,wer},u{id,sh},y},o{am,cus,g,il,l{d,low},o{d,t},r{ce,est,get,k,tune,um,ward},s{sil,ter},und,x},r{a{gile,me},e{quent,sh},i{end,nge},o{g,nt,st,wn,zen},uit},u{el,n{,ny},r{nace,y},ture}} g{a{dget,in,l{axy,lery},me,p,r{age,bage,den,lic,ment},s{,p},t{e,her},uge,ze},e{n{eral,ius,re,tle,uine},sture},host,i{ant,ft,ggle,nger,r{affe,l},ve},l{a{d,nce,re,ss},i{de,mpse},o{be,om,ry,ve,w},ue},o{at,ddess,ld,o{d,se},rilla,s{pel,sip},vern,wn},r{a{b,ce,in,nt,pe,ss,vity},e{at,en},i{d,ef,t},o{cery,up,w},unt},u{ard,ess,i{de,lt,tar},n},ym} h{a{bit,ir,lf,m{mer,ster},nd,ppy,r{bor,d,sh,vest},t,ve,wk,zard},e{a{d,lth,rt,vy},dgehog,ight,l{lo,met,p},n,ro},i{dden,gh,ll,nt,p,re,story},o{bby,ckey,l{d,e,iday,low},me,ney,od,pe,r{n,ror,se},s{pital,t},tel,ur,ver},u{b,ge,m{an,ble,or},n{dred,gry,t},r{dle,ry,t},sband},ybrid} i{c{e,on},d{e{a,ntify},le},gnore,ll{,egal,ness},m{age,itate,m{ense,une},p{act,ose,rove,ulse}},n{c{h,lude,ome,rease},d{ex,icate,oor,ustry},f{ant,lict,orm},h{ale,erit},itial,j{ect,ury},mate,n{er,ocent},put,quiry,s{ane,ect,ide,pire,tall},t{act,erest,o},v{est,ite,olve}},ron,s{land,olate,sue},tem,vory} j{a{cket,guar,r,zz},e{a{lous,ns},lly,wel},o{b,in,ke,urney,y},u{dge,ice,mp,n{gle,ior,k},st}} k{angaroo,e{e{n,p},tchup,y},i{ck,d{,ney},n{d,gdom},ss,t{,chen,e,ten},wi},n{ee,ife,o{ck,w}}} l{a{b{,el,or},d{der,y},ke,mp,nguage,ptop,rge,t{er,in},u{gh,ndry},va,w{,n,suit},yer,zy},e{a{der,f,rn,ve},cture,ft,g{,al,end},isure,mon,n{d,gth,s},opard,sson,tter,vel},i{ar,b{erty,rary},cense,f{e,t},ght,ke,m{b,it},nk,on,quid,st,ttle,ve,zard},o{a{d,n},bster,c{al,k},gic,n{ely,g},op,ttery,u{d,nge},ve,yal},u{cky,ggage,mber,n{ar,ch},xury},yrics} m{a{chine,d,g{ic,net},i{d,l,n},jor,ke,mmal,n{,age,date,go,sion,ual},ple,r{ble,ch,gin,ine,ket,riage},s{k,s,ter},t{ch,erial,h,rix,ter},ximum,ze},e{a{dow,n,sure,t},chanic,d{al,ia},l{ody,t},m{ber,ory},n{tion,u},r{cy,ge,it,ry},s{h,sage},t{al,hod}},i{d{dle,night},l{k,lion},mic,n{d,imum,or,ute},r{acle,ror},s{ery,s,take},x{,ed,ture}},o{bile,d{el,ify},m{,ent},n{itor,key,ster,th},on,r{al,e,ning},squito,t{her,ion,or},u{ntain,se},v{e,ie}},u{ch,ffin,l{e,tiply},s{cle,eum,hroom,ic,t},tual},y{s{elf,tery},th}} n{a{ive,me,pkin,rrow,sty,t{ion,ure}},e{ar,ck,ed,g{ative,lect},ither,phew,rve,st,t{,work},utral,ver,ws,xt},i{ce,ght},o{ble,ise,minee,odle,r{mal,th},se,t{able,e,hing,ice},vel,w},u{clear,mber,rse,t}} o{ak,b{ey,ject,lige,s{cure,erve},tain,vious},c{cur,ean,tober},dor,f{f{,er,ice},ten},il,kay,l{d,ive,ympic},mit,n{ce,e,ion,l{ine,y}},p{e{n,ra},inion,pose,tion},r{ange,bit,chard,d{er,inary},gan,i{ent,ginal},phan},strich,ther,ut{door,er,put,side},v{al,e{n,r}},wn{,er},xygen,yster,zone} p{a{ct,ddle,ge,ir,l{ace,m},n{da,el,ic,ther},per,r{ade,ent,k,rot,ty},ss,t{ch,h,ient,rol,tern},use,ve,yment},e{a{ce,nut,r,sant},lican,n{,alty,cil},ople,pper,r{fect,mit,son},t},h{o{ne,to},rase,ysical},i{ano,c{nic,ture},ece,g{,eon},l{l,ot},nk,oneer,pe,stol,tch,zza},l{a{ce,net,stic,te,y},e{ase,dge},u{ck,g,nge}},o{e{m,t},int,l{ar,e,ice},n{d,y},ol,pular,rtion,s{ition,sible,t},t{ato,tery},verty,w{der,er}},r{a{ctice,ise},e{dict,fer,pare,sent,tty,vent},i{ce,de,mary,nt,ority,son,vate,ze},o{blem,cess,duce,fit,gram,ject,mote,of,perty,sper,tect,ud,vide}},u{blic,dding,l{l,p,se},mpkin,nch,p{il,py},r{chase,ity,pose,se},sh,t,zzle},yramid} qu{a{lity,ntum,rter},estion,i{ck,t,z},ote} r{a{bbit,c{coon,e,k},d{ar,io},i{l,n,se},lly,mp,n{ch,dom,ge},pid,re,t{e,her},ven,w,zor},e{a{dy,l,son},b{el,uild},c{all,eive,ipe,ord,ycle},duce,f{lect,orm,use},g{ion,ret,ular},ject,l{ax,ease,ief,y},m{ain,ember,ind,ove},n{der,ew,t},open,p{air,eat,lace,ort},quire,s{cue,emble,ist,ource,ponse,ult},t{ire,reat,urn},union,v{eal,iew},ward},hythm,i{b{,bon},c{e,h},d{e,ge},fle,g{ht,id},ng,ot,pple,sk,tual,v{al,er}},o{a{d,st},b{ot,ust},cket,mance,o{f,kie,m},se,tate,u{gh,nd,te},yal},u{bber,de,g,le,n{,way},ral}} s{a{d{,dle,ness},fe,il,l{ad,mon,on,t,ute},m{e,ple},nd,t{isfy,oshi},u{ce,sage},ve,y},c{a{le,n,re,tter},ene,h{eme,ool},i{ence,ssors},o{rpion,ut},r{ap,een,ipt,ub}},e{a{,rch,son,t},c{ond,ret,tion,urity},e{d,k},gment,l{ect,l},minar,n{ior,se,tence},r{ies,vice},ssion,t{tle,up},ven},h{a{dow,ft,llow,re},e{d,ll,riff},i{eld,ft,ne,p,ver},o{ck,e,ot,p,rt,ulder,ve},r{imp,ug},uffle,y},i{bling,ck,de,ege,g{ht,n},l{ent,k,ly,ver},m{ilar,ple},n{ce,g},ren,ster,tuate,x,ze},k{ate,etch,i{,ll,n,rt},ull},l{a{b,m},e{ep,nder},i{ce,de,ght,m},o{gan,t,w},ush},m{a{ll,rt},ile,o{ke,oth}},n{a{ck,ke,p},iff,ow},o{ap,c{cer,ial,k},da,ft,l{ar,dier,id,ution,ve},meone,ng,on,r{ry,t},u{l,nd,p,rce,th}},p{a{ce,re,tial,wn},e{ak,cial,ed,ll,nd},here,i{ce,der,ke,n,rit},lit,o{il,nsor,on,rt,t},r{ay,ead,ing},y},qu{are,eeze,irrel},t{a{ble,dium,ff,ge,irs,mp,nd,rt,te,y},e{ak,el,m,p,reo},i{ck,ll,ng},o{ck,mach,ne,ol,ry,ve},r{ategy,eet,ike,ong,uggle},u{dent,ff,mble},yle},u{b{ject,mit,way},c{cess,h},dden,ffer,g{ar,gest},it,mmer,n{,ny,set},p{er,ply,reme},r{e,face,ge,prise,round,vey},s{pect,tain}},w{a{llow,mp,p,rm},e{ar,et},i{ft,m,ng,tch},ord},y{m{bol,ptom},rup,stem}} t{a{ble,ckle,g,il,l{ent,k},nk,pe,rget,s{k,te},ttoo,xi},e{a{ch,m},ll,n{,ant,nis,t},rm,st,xt},h{a{nk,t},e{me,n,ory,re,y},i{ng,s},ought,r{ee,ive,ow},u{mb,nder}},i{cket,de,ger,lt,m{ber,e},ny,p,red,ssue,tle},o{ast,bacco,d{ay,dler},e,gether,ilet,ken,m{ato,orrow},n{e,gue,ight},o{l,th},p{,ic,ple},r{ch,nado,toise},ss,tal,urist,w{ard,er,n},y},r{a{ck,de,ffic,gic,in,nsfer,p,sh,vel,y},e{at,e,nd},i{al,be,ck,gger,m,p},o{phy,uble},u{ck,e,ly,mpet,st,th},y},u{be,ition,mble,n{a,nel},r{key,n,tle}},w{e{lve,nty},i{ce,n,st},o},yp{e,ical}} u{gly,mbrella,n{a{ble,ware},c{le,over},d{er,o},f{air,old},happy,i{form,que,t,verse},known,lock,til,usual,veil},p{date,grade,hold,on,per,set},r{ban,ge},s{age,e{,d,ful,less},ual},tility} v{a{c{ant,uum},gue,l{id,ley,ve},n{,ish},por,rious,st,ult},e{hicle,lvet,n{dor,ture,ue},r{b,ify,sion,y},ssel,teran},i{able,brant,c{ious,tory},deo,ew,llage,ntage,olin,r{tual,us},s{a,it,ual},tal,vid},o{cal,i{ce,d},l{cano,ume},te,yage}} w{a{g{e,on},it,l{k,l,nut},nt,r{fare,m,rior},s{h,p,te},ter,ve,y},e{a{lth,pon,r,sel,ther},b,dding,ekend,ird,lcome,st,t},h{a{le,t},e{at,el,n,re},i{p,sper}},i{d{e,th},fe,l{d,l},n{,dow,e,g,k,ner,ter},re,s{dom,e,h},tness},o{lf,man,nder,o{d,l},r{d,k,ld,ry,th}},r{ap,e{ck,stle},i{st,te},ong}} y{ard,e{ar,llow},ou{,ng,th}} z{e{bra,ro},o{ne,o}} ;;
  esac

check-mnemonic()
  if [[ $# =~ ^(12|15|18|21|24)$ ]]
  then
    local -a wordlist=($(bip39_words))
    local -Ai wordlist_reverse
    local -i i
    local word
    for word in "${wordlist[@]}"
    do wordlist_reverse[$word]=++i
    done

    local dc_script='16o0'
    for word
    do
      if ((${wordlist_reverse[$word]}))
      then dc_script+=" 2048*${wordlist_reverse[$word]} 1-+"
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

complete -W "$(bip39_words)" mnemonic-to-seed
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
      *) openssl kdf -keylen 64 -binary \
          -kdfopt digest:SHA512 \
          -kdfopt pass:"$*" \
          -kdfopt salt:"mnemonic$BIP39_PASSPHRASE" \
          -kdfopt iter:2048 \
          PBKDF2 |
          escape-output-if-needed
        ;;
    esac
  fi
}

create-mnemonic()
  if
    local -a wordlist=($(bip39_words))
    local OPTIND OPTARG o
    getopts h o
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

# bip-0039 code stops here }}}

p2pkh-address() {
  {
    printf %b "${P2PKH_PREFIX:-\x00}"
    cat
  } | base58 -c
}
 
bitcoinAddress()
  if
    local OPTIND o
    getopts ht o
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

# vi: synmaxcol=0 shiftwidth=2
