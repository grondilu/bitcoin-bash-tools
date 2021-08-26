if ! test -v base58
then . base58.sh
fi
. secp256k1.sh

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

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
       version: ("0x"+.[0:8]),
       depth:   ("0x"+.[8:10]),
       fingerprint:   ("0x"+.[10:18]),
       "child number":   ("0x"+.[18:26]),
       "chain code":   ("0x"+.[26:90]),
       key:   ("0x"+.[90:156])
    }'
  fi

serExtendedKey() {
  jq -r '[
      .version,.depth,.fingerprint,."child number",."chain code",.key
    ]|map(.[2:])|join("")' |
  xxd -p -r |
  encodeBase58Check
}

CKDpriv()
  if
    read key
    decodeBase58Check "$key"
  then
    local -i index=$1
    parseExtendedKey <<<"$key" |
    jq -r '[.key, ."chain code"]|join(" ")' |
    {
      read k_par c_par
      {
	if ((index >= 1<<31))
	then
	  printf "\0"
	  ser256 "$k_par"
	else 
	  point "$k_par" |serP
	fi
	ser32 "$index"
      } |
      openssl dgst -sha512 -hmac "$c_par" -binary |
      xxd -u -p -c 64 |
      {
	read
	local left=${REPLY:0:64} right=${REPLY:64:64}
	dc -e "$secp256k1 16doi $left $k_par+ lo%n"
	echo " $right"
      } |
      {
	read k c
	jq -n "{ key: { exponent: \"$k\" }, chainCode: \"$c\" }"
      }
    }
  else
    echo "wrong format (input was $key)" >&2
    return 1
  fi

CKDpub() {
  local -i index=$1
  jq -c . |
  if ((index >= 1<<31))
  then
    1>&2 echo "function is not available for hardened keys"
    return 1
  else
    local json left right
    read json
    {
      jq .key <<<$json |serP 
      ser32 $index
    } | 
    openssl dgst -sha512 -hmac "$(jq -r .chainCode <<<$json)" -binary |
    xxd -u -p -c 64 |
    {
      read
      left=${REPLY:0:64} right=${REPLY:64:64}
      point "0x$left"
      jq .key <<<"$json"
    } |
    add |
    extendKey "$right"
  fi
}

Neuter() {
  jq '{ key: { point: .key.point }, chainCode }'
}
