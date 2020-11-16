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
  for v
  do
    b=$((chk >> 25))
    chk=$(( (chk & 0x1ffffff) << 5^v ))
    for i in {0..4}
    do ((chk^= (b >> i) & 1 ? GEN[i] : 0))
    done
  done
  echo $chk
}
ord() { LC_CTYPE=C printf '%d' "'$1"; }
bech32_hrp_expand() {
  declare -i x
  for x
  do echo $(( x >> 5 ))
  done
  echo 0
  for x
  do echo $(( x & 31 ))
  done
}
bech32_verify_checksum() {
  mapfile -t hrp  < <(echo -n "${1%1*}"  |while read -n 1 c; do ord $c; echo; done)
  mapfile -t data < <(echo -n "${1##*1}" |while read -n 1 c; do echo ${bech32A[$c]}; done)

  test $(
    bech32_polymod $(
      bech32_hrp_expand "${hrp[@]}"
      for x in "${data[@]}"
      do echo $x
      done
    )
  ) -eq 1
}
bech32_create_checksum() {
  mapfile -t hrp  < <(echo -n "${1%1*}"  |while read -n 1 c; do ord $c; echo; done)
  mapfile -t data < <(echo -n "${1##*1}" |while read -n 1 c; do echo ${bech32A[$c]}; done)
  declare -i polymod=$(( $(bech32_polymod $(bech32_hrp_expand ${hrp[@]}) ${data[@]} 0 0 0 0 0 0) ^ 1))
  declare -a checksum
  for i in {0..5}
  do checksum[$i]=$(( (polymod >> 5 * (5 - i)) & 31 ))
  done
  for c in ${hrp[@]}
  do printf "\x$(printf "%x" $c)"
  done
  echo -n 1
  for c in ${data[@]} ${checksum[@]}
  do echo -n ${bech32[$c]}
  done
  echo
}

declare -a valid_checksum=(
  a12uel5l
  an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs
  abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw
  11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j
  split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w
)
for t in "${valid_checksum[@]}"
do bech32_verify_checksum $t
done

bech32_verify_checksum $(bech32_create_checksum foo1zzzzzzzzzz)
bech32_verify_checksum tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx
