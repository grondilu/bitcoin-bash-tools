#!/usr/bin/env bash
# 
# bx.sh, an attempt at a bash port of the Bitcoin eXplorer (BX).
# Original code:  https://github.com/libbitcoin/libbitcoin-explorer

isHexadecimal() [[ "$1" =~ ^[[:xdigit:]]{2}+$ ]]
is64based()     [[ "$1" =~ ^[A-Za-z0-9+/]+=*$ ]]

bx()
  case "$1" in

    # Wallet commands
    seed)
      shift
      local -i length=192
      local o OPTIND
      while getopts b:h o
      do
        case "$o" in
          b) length=$OPTARG;;
          h) cat <<-seed_USAGE
	Usage: bx seed [-h] [-b VALUE]
	
	Info: Generate a pseudorandom seed.                                      
	
	Options (named):
	
	-b                   The length of the seed in bits. Must be divisible by
	                     8 and must not be less than 128, defaults to 192.   
	-h                   Get a description and instructions for this command.
	seed_USAGE
          return
          ;;
        esac
      done
      shift $((OPTIND - 1))
      if ((length >= 128 && length % 8 == 0))
      then openssl rand -hex $((length/8))
      else return 1
      fi ;;
    ec-new)
      shift
      if (($# == 0))
      then read; $FUNCNAME ec-new "$REPLY"
      elif ! isHexadecimal "$1"
      then return 1
      elif ((4*${#1} < 128))
      then
        echo "The seed is less than 128 bits long." >&2
        return 2
      else
        $FUNCNAME base16-decode "$1" |
	openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
        head -c 32 |
        $FUNCNAME base16-encode
      fi
        
      ;;

    # Encoding commands
    address-decode)
      ;;
    address-embed)
      ;;
    address-encode)
      ;;
    base16-encode)
      xxd -p -c 256;;
    base16-decode)
      if (($# < 2))
      then xxd -p -r
      elif isHexadecimal "$2"
      then echo -n "$2" | $FUNCNAME $1
      else return 1
      fi;;
    base58-decode)
      ;;
    base58-encode)
      ;;
    base64-encode)
      openssl base64;;
    base64-decode)
      if (($# < 2))
      then openssl base64 -d
      elif is64based "$2"
      then echo "$2" | $FUNCNAME $1
      else return 1
      fi;;
    base58-decode)
      ;;
    base58-encode)
      ;;

    # Hash commands
    bitcoin160)
      if (($# < 2))
      then
	$FUNCNAME base16-decode |
	openssl dgst -sha256 -binary |
	openssl dgst -rmd160 -binary |
	$FUNCNAME base16-encode
      elif isHexadecimal "$2"
      then echo -n "$2" | $FUNCNAME $1
      else return 1
      fi;;

    # Math commands
    ec-add)
      local -u point="$2" secret="$3"
      if [[ ! "$point" =~ ^0[23][[:xdigit:]]{2}{32}$ ]]
      then return 1
      elif (($# < 2))
      then return 2
      elif (($# < 3))
      then
        read
        $FUNCNAME $1 $2 "$REPLY"
      else
        {
	  echo "$point"
	  secp256k1 "0x$secret"
        } | secp256k1
      fi;;
    ec-add-secrets)
      if (($# == 2))
      then echo "$1"
      elif (($# == 3))
      then secp256k1 "0x$1" "0x$2"
      else return 1
      fi;;
    *)
      echo "NYI" >&2;;
  esac
