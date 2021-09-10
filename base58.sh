declare -a base58_chars_str="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
declare -a base58_chars=(
    1 2 3 4 5 6 7 8 9
  A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
  a b c d e f g h i j k   m n o p q r s t u v w x y z
)
unset dcr; for i in ${!base58_chars[@]}; do dcr+="${i}s${base58_chars[i]}"; done

base58()
  if
    # echo BASE58_OPERATION=$BASE58_OPERATION $FUNCNAME "$@" >&2
    (($# == 0))
  then $FUNCNAME "$(xxd -p |while read; do echo -n "$REPLY"; done)"
  elif
    local OPTIND OPTARG o
    getopts hxdvc o
  then
    shift $((OPTIND - 1))
    case $o in
      d) BASE58_OPERATION=decode-to-binary $FUNCNAME "$@";;
      v) BASE58_OPERATION=verify-checksum  $FUNCNAME "$@";;
      x) $FUNCNAME -d "$@" |
         xxd -p |
         while read; do echo -n $REPLY; done
         echo
        ;;
      c) BASE58_USE_CHECKSUM=yes $FUNCNAME "$@";;
      h)
        cat <<-END_USAGE
	$FUNCNAME [options] [hex or base58 string]
	
	options are:
	  -h:	show this help
	  -d:	decode from base58 to binary
	  -x:	decode from base58 to hexadecimal
	  -c:	append checksum
          -v:	verify checksum
	END_USAGE
        return
        ;;
    esac
  elif [[ "$BASE58_OPERATION" = decode-to-binary ]]
  then
    if [[ "$1" =~ ^1+ ]]
    then printf "\x00"; $FUNCNAME "${1:1}"
    elif [[ "$1" =~ ^[$base58_chars_str]+$ ]]
    then sed -e "i$dcr 0" -e 's/./ 58*l&+/g' -e "aP" <<<"$1" | dc
    else return 2
    fi
  elif [[ "$BASE58_OPERATION" = verify-checksum ]]
  then
    BASE58_OPERATION= $FUNCNAME -d "$1" |
    head -c -4 |
    BASE58_OPERATION= $FUNCNAME -c |
    grep -q "^$1$"
  elif [[ "$BASE58_USE_CHECKSUM" = yes ]]
  then
    {
       xxd -p -r <<<"$1"
       xxd -p -r <<<"$1" |
       openssl dgst -sha256 -binary |
       openssl dgst -sha256 -binary |
       head -c 4
    } | BASE58_USE_CHECKSUM= $FUNCNAME 
  elif [[ "$1" =~ ^00 ]]
  then echo -n 1; $FUNCNAME "${1:2}"
  elif [[ "$1" =~ ^[[:xdigit:]]{2}+$ ]]
  then sed -e 'i16i0' -e 's/../100*&+/g' -e 'a[3A~rd0<x]dsxx+f' <<<"${1^^}" |
    dc |
    while read; do echo -n ${base58_chars[REPLY]}; done
    echo
  else return 9
  fi

decodeBase58() {
  if [[ "$1" =~ ^1+ ]]
  then printf "\x00"; $FUNCNAME "${1:1}"
  elif ((${#1} > 0))
  then
    {
      echo "$dcr 0"
      sed 's/./ 58*l&+/g' <<<"$1"
      echo "P"
    } | dc
  fi
}
encodeBase58() {
  xxd -p -u -c 1 |
  {
    while read
    do
      if [[ "$REPLY" = "00" ]]
      then echo -n 1
      else break
      fi
    done 
    if test -n "$REPLY"
    then local -i n
      {
	echo "16i$REPLY"
	while read
	do echo "100*$REPLY+"
	done
	echo '[3A~rd0<x]dsxx+f'  
      } | dc |
      while read -r n; do echo -n "${base58_chars[n]}"; done
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
