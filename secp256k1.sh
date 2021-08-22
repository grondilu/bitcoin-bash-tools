point()
  if   (( $# == 0 ))
  then $FUNCNAME "0x$(openssl rand -hex 32)"
  elif [[ "$1" =~ ^[[:digit:]]+$ ]]
  then $FUNCNAME "0x$(dc -e "$1 16on")"
  elif [[ "$1" =~ ^0([23])([[:xdigit:]]{64})$ ]]
  then
    dc -f secp256k1.dc -e "16doi [${1^^}]
    ${BASH_REMATCH[1]} ${BASH_REMATCH[2]^^}
    dsxd3lp|rla*+lb+lRx
    [d2%1=_]s2 [d2%0=_]s3
    rd2=2 3=3 lx f" |
    jq -R --slurp './"\n"|{ X: .[0], Y: .[1], compressed: .[2] }'
  elif [[ "$1" =~ ^0x([[:xdigit:]]+)$ ]]
  then
    local e="${BASH_REMATCH[1]^^}"
    dc -f secp256k1.dc -e "16doi$e dlGrlMxlm~f" |
    {
      local x y c
      read y
      read x
      x="$(ser256 "$x" |xxd -p -c64)"
      y="$(ser256 "$y" |xxd -p -c64)"
      if [[ "$y" =~ [02468ACE]$ ]]
      then c=02
      else c=03
      fi
      jq -n "{ X: \"$x\", Y: \"$y\", compressed: \"$c$x\", exponent: \"0x${e,,}\" }"
    }
  else
    1>&2 echo wrong argument format
    return 1
  fi

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
  jq -r .compressed |
  xxd -r -p -c66
}
parseP() {
  point "$(xxd -u -p -c33)"
}

