#!/usr/bin/env bash

base58()
  if
    local -a base58_chars=(
	1 2 3 4 5 6 7 8 9
      A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
      a b c d e f g h i j k   m n o p q r s t u v w x y z
    )
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
        elif [[ "$input" =~ ^[$(printf %s ${base58_chars[@]})]+$ ]]
        then
	  {
	    printf "s%c\n" "${base58_chars[@]}" | nl -v 0
	    sed -e "i0" -e 's/./ 58*l&+/g' -e "aPq" <<<"$input"
	  } | dc
        elif [[ -n "$input" ]]
        then return 1
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
        cat "${1:-/dev/stdin}" |
        tee >(
           openssl dgst -sha256 -binary |
           openssl dgst -sha256 -binary |
	   head -c 4
        ) | ${FUNCNAME[0]}
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
	do echo -n "${base58_chars[REPLY]}"
	done
      fi
      echo
    }
  fi
