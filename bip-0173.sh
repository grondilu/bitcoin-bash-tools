#!/usr/bin/env bash

. bech32.sh

segwitAddress() {
  local OPTIND OPTARG o
  if getopts hp:tv: o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} [-t] [-v witness-version] WITNESS_PROGRAM
	${FUNCNAME[0]} [-t] -p compressed-point
	END_USAGE
        ;;
      p)
        if [[ "$OPTARG" =~ ^0[23][[:xdigit:]]{64}$ ]]
        then ${FUNCNAME[0]} "$@" "$(
          xxd -p -r <<<"$OPTARG" |
          openssl dgst -sha256 -binary |
          openssl dgst -rmd160 -binary |
          xxd -p -c 20
        )"
        else echo "-p option expects a compressed point as argument" >&2
          return 1
        fi
        ;;
      t) HRP=tb ${FUNCNAME[0]} "$@" ;;
      v) WITNESS_VERSION=$OPTARG ${FUNCNAME[0]} "$@" ;;
    esac
  elif
    local hrp="${HPR:-bc}"
    [[ ! "$hrp"     =~ ^(bc|tb)$ ]]
  then return 1
  elif
    local witness_program="$1"
    [[ ! "$witness_program" =~ ^[[:xdigit:]]{2}+$ ]]
  then return 2
  elif
    local -i version=${WITNESS_VERSION:-0}
    ((version < 0))
  then return 3
  elif ((version == 0))
  then
    if [[ "$witness_program" =~ ^.{40}$ ]] # 20 bytes
    then
      # P2WPKH
      bech32_encode "$hrp" $(
	echo $version;
        echo -n "$witness_program" |
	while read -n 2; do echo 0x$REPLY; done |
        convertbits 8 5
      )
    elif [[ "$witness_program" =~ ^.{64}$ ]] # 32 bytes
    then
       1>&2 echo "pay-to-witness-script-hash (P2WSH) NYI"
       return 3
    else
       1>&2 echo For version 0, the witness program must be either 20 or 32 bytes long.
       return 4
    fi
  else return 255
  fi
}

segwit_verify() {
  if ! bech32_decode "$1" >/dev/null
  then return 1
  else
    local hrp
    local -i witness_version
    local -ai bytes
    bech32_decode "$1" |
    {
      read hrp
      [[ "$hrp" =~ ^(bc|tb)$ ]] || return 2
      read witness_version
      (( witness_version < 0 || witness_version > 16)) && return 3
      
      bytes=($(convertbits 5 8 0)) || return 4
      if
	((
	  ${#bytes[@]} == 0 ||
	  ${#bytes[@]} <  2 ||
	  ${#bytes[@]} > 40
	))
      then return 7
      elif ((
	 witness_version == 0 &&
	 ${#bytes[@]} != 20 &&
	 ${#bytes[@]} != 32
      ))
      then return 8
      fi
    }
  fi
}

convertbits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  local -i maxv=$(( (1 << outbits) - 1 ))
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
  if ((pad > 0))
  then
    if ((bits))
    then echo $(( (val << (outbits - bits)) & maxv ))
    fi
  elif (( ((val << (outbits - bits)) & maxv ) || bits >= inbits))
  then return 1
  fi
}

