#!/usr/bin/env bash
# 
# bx.sh, an attempt at a bash port of the Bitcoin eXplorer (BX).
# Original code:  https://github.com/libbitcoin/libbitcoin-explorer

isDecimal()     [[ "$1" =~ ^[[:digit:]]+$ ]]
isHexadecimal() [[ "$1" =~ ^(0x)?([[:xdigit:]]{2}+)$ ]]
is64based()     [[ "$1" =~ ^[A-Za-z0-9+/]+=*$ ]]

isCompressedPoint()   [[ "$1" =~ ^0[23][[:xdigit:]]{2}{32}$ ]]
isUncompressedPoint() [[ "$1" =~    ^04[[:xdigit:]]{2}{64}$ ]]

declare base58=(123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz)
unset dcr; for i in {0..57}; do dcr+="${i}s${base58:$i:1}"; done


declare -a bx_commands=(
  seed
  ec-{new,to-{address,public,wif}}
  electrum-{new,to-seed}
  hd-{new,private,public,to-{ec,public}}
  mnemonic-{new,to-seed}
  qrcode
  uri-{de,en}code
  wif-to-{ec,public}

  address-{{de,en}code,embed}
  {wrap,base{16,58{,check},64}}-{en,de}code

  bitcoin{160,256}
  ripemd160
  sha{160,256,512}

  ec-{add,multiply}{,-secrets}
)

complete -W "${bx_commands[*]}" bx

bx() 
  if
    local OPTIND OPTARG
    getopts h o
  then cat <<-ENDUSAGE
	Usage:
	  $FUNCNAME -h
	  $FUNCNAME COMMAND [options] [arguments]
	
	  COMMAND is any of: ${bx_commands[*]}
	ENDUSAGE
  else
    shift $((OPTIND - 1))
    local -l command="$1"
    shift
    case "$command" in

      # Wallet commands
      seed)
        local -i length=192
        local o
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
        if (($# == 0))
        then read; $FUNCNAME $command "$REPLY"
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
      ec-to-public)
        if
          local format="${BITCOIN_PUBLIC_KEY_FORMAT:-compressed}"
          getopts u u
        then
          shift $((OPTIND - 1))
          BITCOIN_PUBLIC_KEY_FORMAT=uncompressed $FUNCNAME $command "$@"
        elif (($# == 0))
        then read; $FUNCNAME $command "$REPLY"
        elif isDecimal "$1"
        then $FUNCNAME $command "0x$(dc -e "16o$1p")"
        elif isHexadecimal "$1"
	then
          {
	    echo "16doilG${BASH_REMATCH[2]^^}lMxlm~" 
	    if [[ "$format" = compressed ]]
	    then echo "2%2+2 2 8^^*+ P"
	    else echo "r 4 2 2 8^^*+2 2 8^^*+P"
	    fi
          } | dc -f secp256k1.dc - |
          xxd -p -c 65
        else return 1
        fi
        ;;
      ec-to-address)
        if (($# == 0))
        then read; $FUNCNAME ec-to-address "$REPLY"
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
        if (($# == 0))
        then xxd -p -c 256
        else echo -n "$1" | $FUNCNAME $command
        fi
        ;;
      base16-decode)
        if (($# == 0))
        then read; $FUNCNAME $command "$REPLY"
        elif isHexadecimal "$1"
        then xxd -p -r <<<"$1"
        else return 1
        fi;;
      base58-decode)
        if (($# == 0))
        then read; $FUNCNAME $command "$REPLY"
        elif [[ ! "$1" =~ ^[$base58]+$ ]]
        then return 1
        elif [[ "$1" =~ ^1 ]]
        then
          local ones="${1%%[^1]*}"
          echo -n "${ones//?/00}"
          $FUNCNAME $command "${1:${#ones}}"
        else
	  {
	    echo "$dcr 0"
	    sed 's/./ 58*l&+/g' <<<"$1"
	    echo "P"
	  } | dc |
          $FUNCNAME base16-encode
        fi
        ;;
      base58-encode)
        if (($# == 0))
        then read; $FUNCNAME $command "$REPLY"
        elif ! isHexadecimal "$1"
        then return 1
        elif [[ "$1" =~ ^00.+ ]]
        then echo -n 1; $FUNCNAME $command "${1:2}"
        else
          {
	    echo 16i 0
	    echo -n "${1^^}" |
	    fold -w 2 |
	    sed 's/$/r100*+/'
	    echo '[3A~rd0<x]dsxx+f'
          } | dc |
	  while read; do echo -n "${base58:$REPLY:1}"; done
          echo
        fi
        ;;
      base64-encode)
        openssl base64;;
      base64-decode)
        if (($# == 0))
        then openssl base64 -d
        elif is64based "$1"
        then echo "$1" | $FUNCNAME $command
        else return 1
        fi
        ;;
      wrap-encode)
        if local -i version=${VERSION_BYTE:-0}
          getopts v: v
        then
          shift $((OPTIND - 1))
          VERSION_BYTE=$OPTARG $FUNCNAME $command "$@"
        elif isHexadecimal "$1"
        then
          printf "%02x%s\n" $version "$1" |
          {
            read
            echo -n $REPLY
	    $FUNCNAME base16-decode "$REPLY" |
	    openssl sha256 -binary |
	    openssl sha256 -binary |
	    head -c 4 |
	    $FUNCNAME base16-encode
          }
        else return 1
        fi
        ;;
      base58check-encode)
        if local -i version=${VERSION_BYTE:-0}
          getopts v: v
        then
          shift $((OPTIND - 1))
          VERSION_BYTE=$OPTARG $FUNCNAME $command "$@"
        elif (($# == 0))
        then read; $FUNCNAME $command -v $version "$REPLY"
        elif isHexadecimal "$1"
        then
          $FUNCNAME wrap-encode -v $version "$1" |
          $FUNCNAME base58-encode
        else return 1
        fi
        ;;

      # Hash commands
      bitcoin160)
        if (($# == 0))
        then
          $FUNCNAME base16-decode |
          openssl dgst -sha256 -binary |
          openssl dgst -rmd160 -binary |
          $FUNCNAME base16-encode
        elif isHexadecimal "$1"
        then echo -n "$1" | $FUNCNAME $command
        else return 1
        fi
	;;
      bitcoin256)
        if (($# == 0))
        then
          $FUNCNAME base16-decode |
          openssl dgst -sha256 -binary |
          openssl dgst -sha256 -binary |
          $FUNCNAME base16-encode |
          fold -w 2 | tac |tr -d "\n"
          echo
        elif isHexadecimal "$1"
        then echo -n "$1" | $FUNCNAME $command
        else return 1
        fi
        ;;
      ripemd160)
        if (($# == 0))
        then read; $FUNCNAME $command "$REPLY"
        elif isHexadecimal "$1"
        then $FUNCNAME base16-decode "$1" |
          openssl rmd160 -binary |
          $FUNCNAME base16-encode
        else return 1
        fi
        ;;

      # Math commands
      ec-add)
        if (($# == 0))
        then return 1
        elif (($# == 1))
        then read; $FUNCNAME $command "$1" "$REPLY"
        elif local -u point="$1"
          ! isCompressedPoint "$point"
        then return 1
        elif isHexadecimal "$2"
        then dc -f secp256k1.dc -e "16doi$point dlYxr2 2 8^^%lm*+lG${BASH_REMATCH[2]^^}lMxlAxlEx"
        else return 2
        fi
        ;;
      ec-add-secrets)
        local dc_script
        for arg in "$@"
        do
	  if isHexadecimal "$arg"
	  then dc_script+="${BASH_REMATCH[2]^^}+"
	  else return 1
	  fi
        done
        dc -f secp256k1.dc -e "16doi0 $dc_script ln%p"
        ;;
      *)
        echo "$command NYI" >&2
        ;;
    esac
  fi
