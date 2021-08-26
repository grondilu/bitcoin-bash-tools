# BECH32
# see https://en.bitcoin.it/wiki/BIP_0173
if ! test -v bech32
then readonly -a bech32=(
  q p z r y 9 x 8
  g f 2 t v d w 0
  s 3 j n 5 4 k h
  c e 6 m u a 7 l
)
fi
declare -A bech32A
for i in {0..31}
do bech32A[${bech32[i]}]=$i
done
# character class allowed for human readable part
# hopefully this should match the ASCII range 33 .. 126
if ! test -v HRP_CHAR_CLASS
then readonly HRP_CHAR_CLASS="[[:alnum:][:punct:]$+<=>^\`|~]"
fi

bech32_polymod() {
  readonly -a GEN=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  local    -i chk=1 b i v
  while read v
  do
    ((
      b=chk >> 25,
      chk=(chk & 0x1ffffff) << 5^v
    ))
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
bech32_verify_checksum() ((
  $(bech32_decode "${1,,}" | bech32_polymod) == 1
))
bech32_verify() {
  (( ${#1} <= 90 )) || return 1
  [[ "${1,,}" =~ ^($HRP_CHAR_CLASS{1,83})1([02-9ac-hj-np-z]{6,})$ ]] || return 2
  bech32_verify_checksum "${1,,}" || return 3
}
bech32_create_checksum() {
  local hrp="${1%1*}" data="${1##*1}"
  {
    echo -n "$hrp" |
    while read -n 1
    do LC_TYPE=C printf '%d\n' "'$REPLY"
    done |
    bech32_hrp_expand

    echo -n "${1##*1}" |
    while read -n 1 c
    do echo ${bech32A[$c]}
    done
    
    for i in {1..6}; do echo 0; done
  } |
  bech32_polymod |
  {
    read
    local -i polymod=$(($REPLY ^ 1))
    local -a checksum
    for i in {0..5}
    do checksum[i]=$(( (polymod >> 5 * (5 - i)) & 31 ))
    done
    for c in ${checksum[@]}
    do echo -n ${bech32[$c]}
    done
  }
}
