if ! test -v base58
then . base58.sh
fi
. secp256k1.sh

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

chr()
  if (( $1 < 0 || $1 > 255 ))
  then return 1
  else printf "\\$(printf '%03o' "$1")"
  fi

bip32()
  if (( $# == 0 ))
  then
    while read
    do
      if [[ "$REPLY" =~ ^[tx](prv|pub) ]] && decodeBase58Check "$REPLY"
      then continue
      else
        echo "$REPLY is not a valid BIP-32 extended key" >&2
        return 1
      fi
    done
  elif (( $# == 6 ))
  then
    local -i version=$1 depth=$2 fingerprint=$3 childnumber=$4
    local chaincode=$5 key=$6
    if ((
      version != BIP32_TESTNET_PRIVATE_VERSION_CODE &&
      version != BIP32_MAINNET_PRIVATE_VERSION_CODE &&
      version != BIP32_TESTNET_PUBLIC_VERSION_CODE  &&
      version != BIP32_MAINNET_PUBLIC_VERSION_CODE
    ))
    then return 1
    elif ((depth < 0 || depth > 255))
    then return 2
    elif ((fingerprint < 0 || fingerprint > 0xffffffff))
    then return 3
    elif ((childnumber < 0 || childnumber > 0xffffffff))
    then return 4
    elif [[ ! "$chaincode" =~ ^[[:xdigit:]]{64}$ ]]
    then return 5
    elif [[ ! "$key" =~ ^[[:xdigit:]]{66}$ ]]
    then return 6
    else
      {
        ser32 $version
        chr   $depth
        ser32 $fingerprint
        ser32 $childnumber
        xxd -p -r <<<"$chaincode$key"
      } | encodeBase58Check
    fi
  elif [[ "$1" = 'M' ]]
  then
    local -i version=$BIP32_MAINNET_PRIVATE_VERSION_CODE
    if [[ "$BITCOIN_NET" = 'TEST' ]]
    then version=$BIP32_TESTNET_PRIVATE_VERSION_CODE
    fi
    openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
    xxd -u -p -c 64 |
    {
      read
      $FUNCNAME $version 0 0 0 "${REPLY:64:64}" "00${REPLY:0:64}"
    }
  elif [[ "$1" = '/n' ]]
  then
    $FUNCNAME -p |
    {
      local -i version depth pfp index
      local    cc key
      read version depth pfp index
      read cc
      read key
      case $version in
         $((BIP32_TESTNET_PUBLIC_VERSION_CODE)))
           ;;
         $((BIP32_MAINNET_PUBLIC_VERSION_CODE)))
           ;;
         $((BIP32_MAINNET_PRIVATE_VERSION_CODE)))
           version=$BIP32_MAINNET_PUBLIC_VERSION_CODE;;&
         $((BIP32_TESTNET_PRIVATE_VERSION_CODE)))
           version=$BIP32_TESTNET_PUBLIC_VERSION_CODE;;&
         *)
           key="$(secp256k1 "0x$key")"
      esac
      $FUNCNAME $version $depth $pfp $index $cc $key
    }
  elif [[ "$1" = '-p' ]]
  then
    read
    if ! echo -n "$REPLY" |$FUNCNAME
    then return $?
    else
      decodeBase58 "$REPLY" |
      xxd -p -c $((2*(78+4))) |
      {
        read
	printf '%u %u %u %u\n%s\n%s\n' "0x${REPLY:0:8}" "0x${REPLY:8:2}" "0x${REPLY:10:8}" "0x${REPLY:18:8}" "${REPLY:26:64}" "${REPLY:90:66}"
      }
    fi
  elif [[ "$1" =~ ^/([[:digit:]]+)(h?)$ ]]
  then
    local -i index=${BASH_REMATCH[1]}
    test -n "${BASH_REMATCH[2]}" && ((index+= 1<<31))

    : TODO

  elif [[ "$1" = --to-json ]]
  then
    $FUNCNAME -p |
    {
      local -i version depth pfp index
      local    cc key
      read version depth pfp index
      read cc
      read key
      printf '{
         "version": %u,
         "depth": %u,
         "parent fingerprint": %u,
         "child number": %u,
         "chain code": "%s",
         "key": "%s"
      }' $version $depth $pfp $index $cc $key |
      jq .
    }
  else cat <<-USAGE_END
	Usage:
	  $FUNCNAME M
	  $FUNCNAME derivation-path
	  $FUNCNAME version depth parent-fingerprint child-number chain-code key
	  $FUNCNAME --to-json
	  $FUNCNAME -p
	USAGE_END
  fi

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

