if ! test -v base58
then . base58.sh
fi
. secp256k1.sh

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

bip32()
  if [[ "$1" = 'M' ]]
  then
    openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
    xxd -p -u -c 64 |
    {
      read
      local exponent="${REPLY:0:64}" chainCode="${REPLY:64:64}"
      if [[ "$BITCOIN_NET" = 'TEST' ]]
      then ser32 $BIP32_TESTNET_PRIVATE_VERSION_CODE
      else ser32 $BIP32_MAINNET_PRIVATE_VERSION_CODE
      fi
      printf "\x00"      # depth
      ser32 0            # parent's fingerprint is zero for master keys
      ser32 0            # child number is zero for master keys
      ser256 "$chainCode"
      printf "\x00"; ser256 "$exponent"
    } | encodeBase58Check
  elif [[ "$1" = '/n' ]]
  then
    read
    if [[ "$REPLY" =~ ^[tx]prv ]]
    then
      local version json="$(parseExtendedKey <<<"$REPLY")"
      local key="0x$(secp256k1 "$(jq -r ".key" <<<"$json")")"
      if [[ "$REPLY" =~ ^t ]]
      then version="0x$BIP32_TESTNET_PUBLIC_VERSION_CODE"
      else version="0x$BIP32_MAINNET_PUBLIC_VERSION_CODE"
      fi
      jq ". + { version: \"$version\", key: \"$key\" }" <<<"$json" |
      serExtendedKey
    else echo "$REPLY"
    fi
  elif [[ "$1" =~ ^/([[:digit:]]+)(h?)$ ]]
  then
    local -i index=${BASH_REMATCH[1]}
    read
    if test -n "${BASH_REMATCH[2]}"
    then
      [[ "$REPLY" =~ ^[tx]pub ]] && return 1 
      ((index+= 1<<31))
    fi
    local json="$(parseExtendedKey <<<"$REPLY")"
    local data

    if [[ "$REPLY" =~ ^[tx]prv ]]
    then
       local key="$(jq -r .key <<<"$json")"
       if ((index > 1<<31))
       then
         printf "\x00"
         ser256 "$key"
       else secp256k1 "$key" |xxd -p -r -c 66
       fi
       ser32 $index
    elif [[ "$REPLY" =~ ^[tx]pub ]]
    then
      : TODO
    else return 2  # should not happen
    fi |
    openssl dgst -sha512 -hmac "$(jq -r '."chain code"[2:]' <<<"$json")" -binary |
    xxd -p -u -c 64 |
    {
      read
      echo $REPLY
    }
fi

parseExtendedKey()
  if
    read 
    ! decodeBase58Check "$REPLY"
  then
    echo "wrong format (input was $REPLY)" >&2
    return 1
  elif [[ ! "$REPLY" =~ ^(xprv|xpub|tprx|tpub) ]]
  then
    echo "input does not look like a BIP-0032 extended key" >&2
    return 2
  else
    decodeBase58 $REPLY |
    xxd -p -c $((2*(78+4))) |
    jq -R '{
       version:         ("0x"+.[0:8]),
       depth:           ("0x"+.[8:10]),
       fingerprint:     ("0x"+.[10:18]),
       "child number":  ("0x"+.[18:26]),
       "chain code":    ("0x"+.[26:90]),
       key:             ("0x"+.[90:156])
    }'
  fi

serExtendedKey() {
  jq -r '[
      .version,.depth,.fingerprint,."child number",."chain code",.key
    ]|map(.[2:])|join("")' |
  xxd -p -r |
  encodeBase58Check
}

ser32()
  if
    local -i i=$1
    ((i >= 0 && i < 1<<32)) 
  then printf "%08x" $i |xxd -p -r
  else
    1>&2 echo index out of range
    return 1
  fi

ser256()
  if [[ "$1" =~ ^(0x)?([[:xdigit:]]+)$ ]]
  then
    dc -e "16i 2 100^ ${BASH_REMATCH[2]^^}+ P" |
    tail -c 32
  fi

