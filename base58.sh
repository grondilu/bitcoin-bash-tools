#!/usr/bin/env bash

readonly base58_sh
declare base58_chars_str="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
unset dcr; for i in {1..58}; do dcr+="${i}s${base58_chars_str:$i:1}"; done

base58()
  if
    local OPTIND OPTARG o
    getopts hdvc o
  then
    shift $((OPTIND - 1))
    case $o in
      h)
        cat <<-END_USAGE
	${FUNCNAME[0]} [options] [FILE]
	
	options are:
	  -h:	show this help
	  -d:	decode
	  -c:	append checksum
          -v:	verify checksum
	
	${FUNCNAME[0]} encode FILE, or standard input, to standard output.

	With no FILE, encode standard input.
	
	When writing to a terminal, ${FUNCNAME[0]} will escape non-printable characters.
	END_USAGE
        ;;
      d)
        local input
        read -r input < "${1:-/dev/stdin}"
        if [[ "$input" =~ ^1.+ ]]
        then printf "\x00"; ${FUNCNAME[0]} -d <<<"${input:1}"
        elif [[ "$input" =~ ^[$base58_chars_str]+$ ]]
        then sed -e "i$dcr 0" -e 's/./ 58*l&+/g' -e "aP" <<<"$input" | dc
        elif [[ -z "$input" ]]
        then return 0
        else return 1
        fi |
        if [[ -t 1 ]]
        then cat -v
        else cat
        fi
        ;;
      v)
        tee >(${FUNCNAME[0]} -d "$@" |head -c -4 |${FUNCNAME[0]} -c) |
        uniq | { read -r && ! read -r; }
        ;;
      c)
        tee >(
           openssl dgst -sha256 -binary |
           openssl dgst -sha256 -binary |
	   head -c 4
        ) | ${FUNCNAME[0]} "$@"
        ;;
    esac
  else
    xxd -p -u "${1:-/dev/stdin}" |
    tr -d '\n' |
    {
      read hex
      while [[ "$hex" =~ ^00 ]]
      do echo -n 1; hex="${hex:2}"
      done
      if test -n "$hex"
      then
	dc -e "16i0$hex Ai[58~rd0<x]dsxx+f" |
	while read -r
	do echo -n "${base58_chars_str:$REPLY:1}"
	done
      fi
      echo
    }
  fi
