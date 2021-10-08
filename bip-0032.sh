#!/usr/bin/env bash

declare bip32_sh
shopt -s extglob

if ! test -v base58_sh
then . base58.sh
fi

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

isPrivate() ((
  $1 == BIP32_TESTNET_PRIVATE_VERSION_CODE ||
  $1 == BIP32_MAINNET_PRIVATE_VERSION_CODE
))

isPublic() ((
  $1 == BIP32_TESTNET_PUBLIC_VERSION_CODE ||
  $1 == BIP32_MAINNET_PUBLIC_VERSION_CODE
))

fingerprint() {
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary |
  head -c 4
}

debug()
  if [[ "$DEBUG" = yes ]]
  then echo "DEBUG: $@"
  fi >&2

bip32_header() {
  printf "%08x%02x%08x%08x" "$@" |
  xxd -p -r
}

bip32()
  if
    debug "${FUNCNAME[0]} $@"
    local OPTIND OPTARG o
    getopts hts o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	Usage:
	  $FUNCNAME -h
	  $FUNCNAME [-t]
	  $FUNCNAME [-s] derivation-path
	
	$FUNCNAME generates extended keys as defined by BIP-0032.
	When writing to a terminal, $FUNCNAME will print the base58-checked version of the
	serialized key.  Otherwise, it will print the serialized key.
	
	With no argument, $FUNCNAME will generate an extended master key from a binary
	seed read on standard input.  With the -t option, it will generate such key
	for the test network.
	
	With a derivation path as an argument, $FUNCNAME will read a
	seralized extended key from stdin and generate the corresponding derived key.
	
	If the derivation path begins with 'm', $FUNCNAME will expect a master private key as input.
	If the derivation path begins with 'M', $FUNCNAME will expect a master public key as input.
	Otherwise the derivation path begins with '/', then $FUNCNAME will derive any key read from
	standard input.
	
	When expecting a serialized key from stdin, $FUNCNAME will only read the first 78 bytes.
	
	With the -s option, input is interpreted as a seed, not as a serialized key.
	With the -t option, input is interpreted as a seed, and a testnet master key is generated.
	END_USAGE
        ;;
      s) 
        local -i version
        if [[ "$BITCOIN_NET" = 'TEST' ]]
        then version=$BIP32_TESTNET_PRIVATE_VERSION_CODE
        else version=$BIP32_MAINNET_PRIVATE_VERSION_CODE
        fi
        {
          bip32_header $version 0 0 0
          openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
          xxd -u -p -c 32 |
          tac |
          sed 2i00 |
          xxd -p -r
        } |
        ${FUNCNAME[0]} "$@"
        ;;
      t) BITCOIN_NET=TEST ${FUNCNAME[0]} -s "$@";;
    esac
  elif (( $# > 1 ))
  then
    echo "too many parameters given : $@" >&2
    return 1
  elif [[ "$1" =~ ^[mM]?(/([[:digit:]]+h?|N))*$ ]]
  then
    local path="$1"

    local hexdump="$(head -c 78 |xxd -p -c 78)"
    if (( ${#hexdump} < 2*78 ))
    then echo "input is too short" >&2; return 2
    fi

    local -i      version="0x${hexdump:0:8}"
    local -i        depth="0x${hexdump:8:2}"
    local -i    parent_fp="0x${hexdump:10:8}"
    local -i child_number="0x${hexdump:18:8}"
    local      chain_code="${hexdump:26:64}"
    local             key="${hexdump:90:66}"

    # sanity checks
    if [[ "$path" =~ ^m ]] && ((
      version != BIP32_TESTNET_PRIVATE_VERSION_CODE &&
      version != BIP32_MAINNET_PRIVATE_VERSION_CODE
    ))
    then return 2
    elif [[ "$path" =~ ^M ]] && ((
      version != BIP32_TESTNET_PUBLIC_VERSION_CODE &&
      version != BIP32_MAINNET_PUBLIC_VERSION_CODE
    ))
    then return 3
    elif [[ "$path" =~ ^[mM] ]] && ((depth > 0))
    then return 4
    elif [[ "$path" =~ ^[mM] ]] && ((parent_fp > 0))
    then return 5
    elif [[ "$path" =~ ^[mM] ]] && ((child_number > 0))
    then return 6
    elif [[ ! "$key" =~ ^0[023] ]]
    then echo "unexpected key: $key (hexdump is $hexdump)" >&2; return 7
    elif ((
      version != BIP32_TESTNET_PRIVATE_VERSION_CODE &&
      version != BIP32_MAINNET_PRIVATE_VERSION_CODE &&
      version != BIP32_TESTNET_PUBLIC_VERSION_CODE  &&
      version != BIP32_MAINNET_PUBLIC_VERSION_CODE
    ))
    then return 8
    elif ((depth < 0 || depth > 255))
    then return 9
    elif ((parent_fp < 0 || parent_fp > 0xffffffff))
    then return 10
    elif ((child_number < 0 || child_number > 0xffffffff))
    then return 11
    elif isPublic  $version && [[ "$key" =~ ^00    ]]
    then return 12
    elif isPrivate $version && [[ "$key" =~ ^0[23] ]]
    then return 13
    # TODO: check that the point is on the curve?
    fi
    
    path="${path#[mM]}"
    if test -z "$path"
    then
      xxd -p -r <<<"$hexdump" |
      if [[ -t 1 ]]
      then base58 -c
      else cat
      fi
      return
    fi

    coproc DC { dc -f secp256k1.dc -; }
    while [[ "$path" =~ ^/(N|[[:digit:]]+h?) ]]
    do  
      path="${path#/${BASH_REMATCH[1]}}"
      local operator="${BASH_REMATCH[1]}" 
      case "$operator" in
        N)
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
              echo "8d+doilG${key^^}lMxlEx" >&"${DC[1]}"
              read key <&"${DC[0]}"
          esac
          ;;
        +([[:digit:]])h)
          child_number=$(( ${operator%h} + (1 << 31) ))
          ;&
        +([[:digit:]]))

          local parent_id
          if [[ ! "$operator" =~ h$ ]]
          then child_number=$operator
          fi

          if isPrivate "$version"
          then # CKDpriv

            echo "8d+doilG${key^^}lMxlEx" >&"${DC[1]}"
            read parent_id <&"${DC[0]}"
            {
	      {
		if (( child_number >= (1 << 31) ))
		then
		  printf "\x00"
		  ser256 "0x${key:2}" || echo "WARNING: ser256 return $?" >&2
		else
		  xxd -p -r <<<"$parent_id"
		fi
		ser32 $child_number
	      } |
	      openssl dgst -sha512 -mac hmac -macopt hexkey:"$chain_code" -binary |
	      xxd -p -u -c 32 |
	      {
		 read left
		 read right
		 echo "8d+doi$right ${key^^} $left+ln%p"
	      }
            } >&"${DC[1]}"

            read key <&"${DC[0]}"

            while ((${#key} < 66))
            do key="0$key"
            done
          elif isPublic "$version"
          then # CKDpub
            parent_id="$key"
            if (( child_number >= (1 << 31) ))
            then return 4
            else
              {
		{
		  xxd -p -r <<<"$key"
		  ser32 $child_number
		} |
		openssl dgst -sha512 -mac hmac -macopt hexkey:$chain_code -binary |
		xxd -p -u -c 32 |
		{
		   read left
		   read right
		   echo "8d+doi$right lG$left lMx ${key^^}l>xlAxlEx"
		}
              } >&"${DC[1]}"
              read key <&"${DC[0]}"
            fi
          else
            echo "version is neither private nor public?!" >&2
            return 111
          fi
	  parent_fp="0x$(xxd -p -r <<<"$parent_id"|fingerprint |xxd -p)"
          echo rp >&"${DC[1]}"
	  read chain_code <&"${DC[0]}"
          while ((${#chain_code} < 64))
          do chain_code="0$chain_code"
          done
          ((depth++))
          ;;
      esac 
    done
    echo q >&"${DC[1]}"

    {
      bip32_header $version $depth $parent_fp $child_number
      xxd -p -r <<<"$chain_code$key"
    } |
    if [[ -t 1 ]]
    then base58 -c
    else cat
    fi

  else return 255
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
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{65,})$ ]]
  then echo "unexpectedly large parameter" >&2; return 1
  elif   [[ "$1" =~ ^(0x)?([[:xdigit:]]{64})$ ]]
  then xxd -p -r <<<"${BASH_REMATCH[2]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,63})$ ]]
  then $FUNCNAME "0x0${BASH_REMATCH[2]}"
  else return 1
  fi

