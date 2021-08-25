if [[ ! -f secp256k1.dc ]]
then
  1>&2 echo "could not find dc script file"
fi

point()
  if [[ "$1" =~ ^-h|--help$ ]]
  then
    cat <<-EOF
	Usage:
	  point [exponent]
	  point -h|--help
	
	Display the compressed coordinates of a point on the secp256k1 curve
	given an exponent.
	
	Exponent is a natural integer in either decimal or hexadecimal format
	(with the 0x prefix for hexadecimal).
	
	If no exponent is given, a random one will be generated with 'openssl
	rand -hex 32'
	EOF
  elif (( $# == 0 ))
  then $FUNCNAME "0x$(openssl rand -hex 32)"
  elif [[ "$1" =~ ^[[:digit:]]+$ ]]
  then $FUNCNAME "0x$(dc -e "$1 16on")"
  elif [[ "$1" =~ ^0x([[:xdigit:]]+)$ ]]
  then
    dc -f secp256k1.dc -e "16doi${BASH_REMATCH[1]^^}dlGrlMxlm~rf" |
    compressPoint
  else
    1>&2 echo wrong argument format
    return 1
  fi

uncompressPoint() {
  echo -n "04"
  dc -f secp256k1.dc -e "16doi$1dlYxr2 2 8^^%f" |
  while read
  do ser256 "$REPLY"
  done |
  xxd -p -u -c 128
}
compressPoint() {
  local x y
  read x
  read y
  x="$(ser256 "$x" |xxd -u -p -c64)"
  y="$(ser256 "$y" |xxd -u -p -c64)"
  if [[ "$y" =~ [02468ACE]$ ]]
  then echo "02$x"
  else echo "03$x"
  fi
}
add() {
  if [[ "$1" =~ ^-h|--help$ ]]
  then
    cat <<-END
	Usage: add [-h|--help]
	
	Read compressed secp256k1 point coordinates on stdin and outputs the
	compressed coordinates of the sum of the corresponding points.
	END
  else
    {
      echo 16doi0
      sed 's/.*/&dlYxr2 2 8^^%lm*+lAx/'
      echo 'lm~rf'
    } |
    dc -f secp256k1.dc - |
    compressPoint
  fi
}
ser32()
  if
    local -i i=$1
    ((i >= 0 && i < 1<<32)) 
  then dc -e "2 32^ $i+ P" |tail -c 4
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

parse256() { xxd -u -p -c32; }
serP() {
  jq -r .point |
  xxd -r -p -c66
}
parseP() {
  point "$(xxd -u -p -c33)"
}

