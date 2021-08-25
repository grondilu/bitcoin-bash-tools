declare -a base58=(
    1 2 3 4 5 6 7 8 9
  A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
  a b c d e f g h i j k   m n o p q r s t u v w x y z
)
unset dcr; for i in ${!base58[@]}; do dcr+="${i}s${base58[i]}"; done

decodeBase58() {
  if [[ "$1" =~ ^1+ ]]
  then echo ${BASH_REMATCH//?/00}
  fi | xxd -p -r
  {
    echo "$dcr 0"
    sed 's/./ 58*l&+/g' <<<"$1"
    echo "P"
  } | dc
}
encodeBase58() {
  xxd -p -c1 |
  {
    while read
    do
      if [[ "$REPLY" = "00" ]]
      then echo -n 1
      else break
      fi
    done 
    if test -n "$REPLY"
    then
      {
	echo "16i${REPLY^^}"
	while read
	do echo "100*${REPLY^^}+"
	done
	echo '[3A~rd0<x]dsxx+f'  
      } | dc |
      while read -r n; do echo -n "${base58[n]}"; done
    fi
    echo
  }
}
checksum() {
  openssl dgst -sha256 -binary |
  openssl dgst -sha256 -binary |
  head -c 4
}
encodeBase58Check() {
  local tmpfile="$(mktemp)"
  cat > "$tmpfile"
  cat "$tmpfile" <(checksum < "$tmpfile") |
  encodeBase58
  rm  "$tmpfile"
}
decodeBase58Check() {
  [[ "$1" = "$(
    decodeBase58 $1 |
    head -c -4 |
    encodeBase58Check
  )" ]]
}
