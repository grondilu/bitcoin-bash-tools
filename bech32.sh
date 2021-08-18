# BECH32
# see https://en.bitcoin.it/wiki/BIP_0173
declare -a bech32=(
  q p z r y 9 x 8
  g f 2 t v d w 0
  s 3 j n 5 4 k h
  c e 6 m u a 7 l
)
declare -A bech32A
for i in {0..31}
do bech32A[${bech32[$i]}]=$i
done

bech32_polymod() {
  declare -ia GEN=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  declare -i  chk=1 b i v
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
bech32_encode() {
  local hrp="$1" data="$2"
  [[ "$hrp" =~ ^([[:alnum:][:punct:]$+<=>^\`|~]{1,83})$ ]] || return 1 # unexpected format for hrp
  [[ "$data" =~ ^[[:xdigit:]]+$ ]]               || return 2 # unexpected format for data
  (( ${#data} & 1 ))                             && return 3 # unexpected length for data
  local -i i n=$((${#data}*4/5))
  {
  echo -n "${hrp}1"
  dc -e "$n sn 16i ${data^^} [20 ~r ln1-dsn0<x]dsxx +f" |
  while read i
  do echo -n ${bech32[i]}
  done
  } |
  {
     read hrp1data
     echo -n "$hrp1data"
     bech32_checksum "$_"
     echo
  }
}
bech32_decode() {
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
  # hrp character set is only approximated here
  # data character set is more rigorous
  [[ "${s,,}" =~ ^([[:alnum:][:punct:]$+<=>^\`|~]{1,83})1([02-9ac-hj-np-z]{6,})$ ]] || return 2
  bech32_verify_checksum "$s" || return 3
}
bech32_checksum() {
  declare -i polymod=$(($({ bech32_decode "$1"; for i in {1..6}; do echo 0; done; } | bech32_polymod ) ^ 1))
  declare -a checksum
  for i in {0..5}
  do checksum[$i]=$(( (polymod >> 5 * (5 - i)) & 31 ))
  done
  for c in ${checksum[@]}
  do echo -n ${bech32[$c]}
  done
}
