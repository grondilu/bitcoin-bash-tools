# BECH32
# see https://en.bitcoin.it/wiki/BIP_0173
readonly -a bech32=(
  q p z r y 9 x 8
  g f 2 t v d w 0
  s 3 j n 5 4 k h
  c e 6 m u a 7 l
)
# character class allowed for human readable part
# hopefully this should match the ASCII range 33 .. 126
readonly HRP_CHAR_CLASS="[[:alnum:][:punct:]$+<=>^\`|~]"

convert_bits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  readonly maxv=$(((1 << outbits) - 1))
  mapfile -t values
  for ((i=0;i<${#values[@]};i++))
  do
    val=$(((val<<inbits)|${values[i]}))
    ((bits+=inbits))
    while ((bits >= outbits))
    do
      (( bits-=outbits ))
      echo $(( (val >> bits) & maxv ))
    done
  done
  if test -n "$pad"
  then
    if ((bits))
    then echo $(( (val << (outbits - bits)) & maxv ))
    fi
  elif (( ((val << (outbits - bits)) & maxv ) || bits >= inbits))
  then 
    1>&2 echo unexpected outcome
    return 1
  fi
}
bech32_polymod() {
  readonly -a GEN=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  local    -i chk=1 b i v
  while read v
  do
    b=$((chk >> 25))
    chk=$(( (chk & 0x1ffffff) << 5^v ))
    for i in {0..4}
    do ((chk^= (b >> i) & 1 ? GEN[i] : 0))
    done
  done
  echo $chk
}
bech32_hrp_expand() {
  mapfile -t values
  for x in ${values[@]}
  do echo $(( x >> 5 ))
  done
  echo 0
  for x in ${values[@]}
  do echo $(( x & 31 ))
  done
}
bech32_decode() {
  local -A bech32A
  for i in {0..31}
  do bech32A[${bech32[i]}]=$i
  done
  echo -n "${1%1*}" |
  while read -n 1 c
  do LC_CTYPE=C printf '%d\n' "'$c"
  done |
  bech32_hrp_expand
  echo -n "${1##*1}" |
  while read -n 1 c
  do echo ${bech32A[$c]}
  done
}
bech32_verify_checksum() {
  bech32_decode "${1,,}" | bech32_polymod | grep -q '^1$'
}
bech32_verify() {
  local s="${1,,}"
  (( ${#s} > 90 )) && return 1
  [[ "${s,,}" =~ ^($HRP_CHAR_CLASS{1,83})1([02-9ac-hj-np-z]{6,})$ ]] || return 2
  bech32_verify_checksum "$s" || return 3
}
bech32_checksum() {
  local -i polymod=$(($({ bech32_decode "$1"; for i in {1..6}; do echo 0; done; } | bech32_polymod ) ^ 1))
  local -a checksum
  for i in {0..5}
  do checksum[i]=$(( (polymod >> 5 * (5 - i)) & 31 ))
  done
  for c in ${checksum[@]}
  do echo -n ${bech32[$c]}
  done
}
segwit_encode() {
  local hrp="$1" version="$2" data="${3^^}"
  [[ "$hrp"     =~ ^$HRP_CHAR_CLASS{1,83}$ ]] || return 1 # unexpected format for hrp
  [[ "$version" =~ ^0|[1-9][[:digit:]]*$   ]] || return 2 # unexpected format for hrp
  [[ "$data"    =~ ^[[:xdigit:]]{2}+$      ]] || return 3 # unexpected format for data
  if ((version == 0))
  then
    local -i length=$((${#data}/2))
    if ((length == 20))
    then
      # P2WPKH
      {
        echo -n "${hrp}1${bech32[version]}"
        echo -n "$data" |
        while read -n 2
        do printf "%d\n" 0x$REPLY
        done |
        convert_bits 8 5 |
        while read i
        do echo -n ${bech32[i]}
        done
      } |
      {
         read
         echo -n "$REPLY"
         bech32_checksum "$REPLY"
         echo
      }
    elif ((length == 32))
    then
       1>&2 echo "pay-to-witness-script-hash (P2WSH) NYI"
       return 4
    else
       1>&2 echo For version 0, the witness program must be either 20 or 32 bytes long.
       return 5
    fi
  else
    1>&2 echo witness version NYI
    return 6
  fi
}
