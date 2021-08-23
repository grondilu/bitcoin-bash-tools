point()
  if   (( $# == 0 ))
  then $FUNCNAME "0x$(openssl rand -hex 32)"
  elif [[ "$1" =~ ^[[:digit:]]+$ ]]
  then $FUNCNAME "0x$(dc -e "$1 16on")"
  elif [[ "$1" =~ ^0[23][[:xdigit:]]{64}$ ]]
  then jq -n "{ point: \"$1\" }"
  elif [[ "$1" =~ ^0x([[:xdigit:]]+)$ ]]
  then
    local e="${BASH_REMATCH[1]^^}"
    dc -f secp256k1.dc -e "16doi$e dlGrlMxlm~f" |
    $FUNCNAME - |
    jq ". + { exponent: \"0x$e\" }"
  elif [[ "$1" = '-' ]]
  then
    local x y
    read y
    read x
    x="$(ser256 "$x" |xxd -u -p -c64)"
    y="$(ser256 "$y" |xxd -u -p -c64)"
    if [[ "$y" =~ [02468ACE]$ ]]
    then $FUNCNAME "02$x"
    else $FUNCNAME "03$x"
    fi
  else
    1>&2 echo wrong argument format
    return 1
  fi

add() {
  {
    echo 16doi0
    jq -r '"\(.point)lYxlm*+lAx"'
    echo 'lm~f'
  } |
  dc -f secp256k1.dc - |
  point -
}
ser32()
  if
    local -i i=$1
    ((i > 0 && i < 1<<32)) 
  then dc -e "2 32^ $i+ P" |tail -c 4
  fi

ser256()
   if [[ "$1" =~ ^[[:xdigit:]]+$ ]]
   then dc -e "16i 2 100^ ${1^^}+ P" |tail -c 32
   fi

parse256() { xxd -u -p -c32; }
serP() {
  jq -r .point |
  xxd -r -p -c66
}
parseP() {
  point "$(xxd -u -p -c33)"
}

