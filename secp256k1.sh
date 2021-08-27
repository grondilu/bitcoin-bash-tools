if [[ ! -f secp256k1.dc ]]
then
  1>&2 echo "could not find dc script file"
fi

secp256k1()
  if (( $# == 0 ))
  then
    {
      echo 16doi0
      sed 's/.*/&dlYxr2 2 8^^%lm*+lAx/'
      echo lEx
    } | dc -f secp256k1.dc -
  elif [[ "$1" = '-u' ]]
  then shift
    dc -f secp256k1.dc -e "4 2 512^*16doi$1dlYxr2 2 8^^%2 2 8^^*++P" |
    xxd -p -u -c 65
  elif (( $# > 1 ))
  then
    {
      echo 0
      for i in "$@"
      do
        if [[ "$i" =~ ^[[:digit:]]+$ ]]
        then echo "5d+i$i+"
	elif [[ "$i" =~ ^0x([[:xdigit:]]+)$ ]]
        then echo "8d+i${BASH_REMATCH[1]^^}+"
        fi
      done
      echo 'lo%[0x]P8d+op'
    } | dc -f secp256k1.dc -
  elif [[ "$1" =~ ^[[:digit:]]+$ ]]
  then $FUNCNAME "0x$(dc -e "$1 16on")"
  elif [[ "$1" =~ ^0x([[:xdigit:]]+)$ ]]
  then dc -f secp256k1.dc -e "16doi${BASH_REMATCH[1]^^}dlGrlMxlEx"
  else
    cat <<-EOF
	Usage:
	  secp256k1 [exponent]
	
	Display the compressed coordinates of a point on the secp256k1 curve
	given an exponent.
	
	Exponent is a natural integer in either decimal or hexadecimal format
	(with the 0x prefix for hexadecimal).
	
	If no exponent is given, a random one will be generated with 'openssl
	rand -hex 32'
	EOF
  fi

parse256() { xxd -u -p -c32; }
parseP() {
  secp256k1 "$(xxd -u -p -c33)"
}

