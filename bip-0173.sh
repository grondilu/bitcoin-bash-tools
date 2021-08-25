if ! . bech32.sh
then
  1>&2 echo "can't load bech32 script"
  exit 1
fi

segwit_encode() {
  local hrp="$1" version="$2" tmpfile="$(mktemp)"
  [[ "$hrp"     =~ ^$HRP_CHAR_CLASS{1,83}$ ]] || return 1 # unexpected format for hrp
  [[ "$version" =~ ^0|[1-9][[:digit:]]*$   ]] || return 2 # unexpected format for version
  if ((version == 0))
  then
    cat > "$tmpfile"
    local -i length=$(wc -c < "$tmpfile")
    if ((length == 20))
    then
      # P2WPKH
      {
        echo -n "${hrp}1${bech32[$version]}"
        xxd -p -c 1 "$tmpfile" |
        while read
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
        bech32_create_checksum "$REPLY"
        echo
      }
      rm "$tmpfile"
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

convert_bits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  readonly maxv=$(((1 << outbits) - 1))
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
