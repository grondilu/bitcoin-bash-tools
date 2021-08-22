declare secp256k1='
I16i7sb0sa[[_1*lm1-*lm%q]Std0>tlm%Lts#]s%[Smddl%x-lm/rl%xLms#]s~
483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
2 100^d14551231950B75FC4402DA1732FC9BEBF-so1000003D1-ddspsm*+sGi
[_1*l%x]s_[+l%x]s+[*l%x]s*[-l%x]s-[l%xsclmsd1su0sv0sr1st[q]SQ[lc
0=Qldlcl~xlcsdscsqlrlqlu*-ltlqlv*-lulvstsrsvsulXx]dSXxLXs#LQs#lr
l%x]sI[lpSm[+q]S0d0=0lpl~xsydsxd*3*lal+x2ly*lIx*l%xdsld*2lx*l-xd
lxrl-xlll*xlyl-xrlp*+Lms#L0s#]sD[lpSm[+q]S0[2;AlDxq]Sdd0=0rd0=0d
2:Alp~1:A0:Ad2:Blp~1:B0:B2;A2;B=d[0q]Sx2;A0;B1;Bl_xrlm*+=x0;A0;B
l-xlIxdsi1;A1;Bl-xl*xdsld*0;Al-x0;Bl-xd0;Arl-xlll*x1;Al-xrlp*+L0
s#Lds#Lxs#Lms#]sA[rs.0r[rl.lAxr]SP[q]sQ[d0!<Qd2%1=P2/l.lDxs.lLx]
dSLxs#LPs#LQs#]sM[lpd1+4/r|]sR
'

exponent()
  if (( $# == 0 ))
  then $FUNCNAME "$(openssl rand -hex 32)"
  elif [[ "$1" =~ ^[[:xdigit:]]+$ ]]
  then jq -n "{ \"exponent\": \"${1^^}\" }"
  else
    1>&2 echo wrong argument format
    return 1
  fi

point() {
  dc -e "$secp256k1 $(jq -r .exponent)d lGr lMx 16olm~ f" |
  jq -R --slurp './"\n"|{ "exponent": .[2], "point": { "X": .[1], "Y": .[0] } }'
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
  jq -r '[.X,.Y]|join(" ")' |
  {
    read x y
    dc -e "16i[2Pq]sp $y 2%0=p 3P"
    ser256 $x
  }
}
parseP() {
  {
    echo "${secp256k1}16doi"
    xxd -u -p -c33 |
    jq -R -r .[0:2],.[2:]
    echo 'dsxd3lp|rla*+lb+lRx
    [d2%1=_]s2 [d2%0=_]s3
    rd2=2 3=3 lx f'
  } | dc |
  jq -R --slurp './"\n"|{ "X": .[0], "Y": .[1] }'
}

