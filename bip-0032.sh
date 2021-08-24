. secp256k1.sh

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

parseExtendedKey() {
  xxd -u -p -c 82 |
  jq -R '{
    version: ("0x"+.[0:8]),
    depth:   ("0x"+.[8:10]),
    parentFP: ("0x"+.[10:18]),
    childIndex: ("0x"+.[18:26]),
    chainCode: ("0x"+.[26:90]),
    key: ("0x"+.[90:156]),
    checksum: ("0x"+.[156:]),
  }'
}
extendKey() {
  jq "{ key: ., chainCode: \"${1:-$(openssl rand -hex 32)}\" }"
}

fingerPrint() {
  jq .key |
  serP |
  head -c4 |
  xxd -p -c8
}

CKDpriv() {
  local -i index=$1
  jq -r '[.key.exponent, .chainCode]|join(" ")' |
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
      dc -e "$secp256k1 16doi $left $(printf "%X" $k_par)+ lo%n"
      echo " $right"
    } |
    {
      read k c
      jq -n "{ key: { exponent: \"$k\" }, chainCode: \"$c\" }"
    }
  }
}

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
