#!/bin/bash
#GenFirstWordsAndAddress.bash
#CREDIT: https://github.com/grondilu/bitcoin-bash-tools Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
#LICENSE: SPDX MIT https://spdx.org/licenses/MIT.html
#SUPPORT: https://github.com/petjal/bitcoin-bash-tools/issues
#This script: github:petjal Thu Sep 23 14:59:23 UTC 2021
#VERSION: 2110010242Z
#CHANGE: pj wordlist to array per grondilu
#TODO: make work also on windows linux (wsl) terminal 
#TODO: add verification tests
#TODO: trap errors, bail on everything
#TODO: make work also on macos (I tried, failed)
#TODO: remove dependencies on dc, ent? 
 
#USAGE:
#For use by technical folks to help beginners among family, friends, confidants get started safely as simply as possible
#Open a terminal on gnu/linux. (Not yet tested on windows, mac. Developed initially on chromebook in termux).
#Get signed file bundle. 
#Check bundle signature.
#Extract signed file bundle.
#Run:  cd ./bitcoin-bash-tools
#Run:  bash GenSimplestAddress.bash

#REQUIREMENTS: Install dc, ent, openssl. 

#CONSTANTS

#secp256k1.dc
#CREDIT: https://raw.githubusercontent.com/grondilu/bitcoin-bash-tools/master/secp256k1.dc
# Copyright (C) 2013-2021 Lucien Grondin (grondilu@yahoo.fr)
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
#

secp256k1_dc='I16i7sb0sa[[_1*lm1-*lm%q]Std0>tlm%Lts#]s%[Smddl%x-lm/rl%xLms#]s~
483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
2 100^ds<d14551231950B75FC4402DA1732FC9BEBF-sn1000003D1-dspsml<*
+sGi[_1*l%x]s_[+l%x]s+[*l%x]s*[-l%x]s-[l%xsclmsd1su0sv0sr1st[q]
SQ[lc0=Qldlcl~xlcsdscsqlrlqlu*-ltlqlv*-lulvstsrsvsulXx]dSXxLXs#
LQs#lrl%x]sI[lpd1+4/r|]sR[lpSm[+lCxq]S0[l1lDxlCxq]Sd[0lCxq]SzdS1
rdS2r[L0s#L1s#L2s#Lds#Lms#LCs#]SCd0=0rd0=0r=dl1l</l2l</l-xd*l1l<
%l2l<%l+xd*+0=zl2l</l1l</l-xlIxl2l<%l1l<%l-xl*xd2lm|l1l</l2l</+
l-xd_3Rl1l</rl-xl*xl1l<%l-xrl<*+lCx]sA[lpSm[LCxq]S0dl<~SySx[Lms#
L0s#LCs#Lxs#Lys#]SC0=0lxd*3*la+ly2*lIxl*xdd*lx2*l-xd_3Rlxrl-xl*x
lyl-xrl<*+lCx]sD[rs.0r[rl.lAxr]SP[q]sQ[d0!<Qd2%1=P2/l.lDxs.lLx]d
SLxs#LPs#LQs#]sM[[d2%1=_q]s2 2 2 8^^~dsxd3lp|rla*+lb+lRxr2=2d2%0
=_]sY[2l<*2^+]sU[d2%2+l<*rl</+]sC[[L0s#0pq]S0d0=0l<~2%2+l<*+[0]
Pp]sE'






#WORDLIST
#CREDIT: gronilu https://github.com/grondilu/bitcoin-bash-tools/discussions/35
#!/usr/bin/env bash
#. pbkdf2.sh  # TODO: need to import here?  Maybe not, seems ok so far. 
# list of words from
# https://github.com/trezor/python-mnemonic/blob/master/src/mnemonic/wordlist/english.txt
declare -a bip39_wordlist=(
  abandon ability able about above absent absorb abstract absurd abuse
  access accident account accuse achieve acid acoustic acquire across act
  action actor actress actual adapt add addict address adjust admit adult
  advance advice aerobic affair afford afraid again age agent agree ahead
  aim air airport aisle alarm album alcohol alert alien all alley allow
  almost alone alpha already also alter always amateur amazing among amount
  amused analyst anchor ancient anger angle angry animal ankle announce
  annual another answer antenna antique anxiety any apart apology appear
  apple approve april arch arctic area arena argue arm armed armor army
  around arrange arrest arrive arrow art artefact artist artwork ask aspect
  assault asset assist assume asthma athlete atom attack attend attitude
  attract auction audit august aunt author auto autumn average avocado
  avoid awake aware away awesome awful awkward axis baby bachelor bacon
  badge bag balance balcony ball bamboo banana banner bar barely bargain
  barrel base basic basket battle beach bean beauty because become beef
  before begin behave behind believe below belt bench benefit best betray
  better between beyond bicycle bid bike bind biology bird birth bitter
  black blade blame blanket blast bleak bless blind blood blossom blouse
  blue blur blush board boat body boil bomb bone bonus book boost border
  boring borrow boss bottom bounce box boy bracket brain brand brass brave
  bread breeze brick bridge brief bright bring brisk broccoli broken bronze
  broom brother brown brush bubble buddy budget buffalo build bulb bulk
  bullet bundle bunker burden burger burst bus business busy butter buyer
  buzz cabbage cabin cable cactus cage cake call calm camera camp can canal
  cancel candy cannon canoe canvas canyon capable capital captain car carbon
  card cargo carpet carry cart case cash casino castle casual cat catalog
  catch category cattle caught cause caution cave ceiling celery cement
  census century cereal certain chair chalk champion change chaos chapter
  charge chase chat cheap check cheese chef cherry chest chicken chief child
  chimney choice choose chronic chuckle chunk churn cigar cinnamon circle
  citizen city civil claim clap clarify claw clay clean clerk clever click
  client cliff climb clinic clip clock clog close cloth cloud clown club
  clump cluster clutch coach coast coconut code coffee coil coin collect
  color column combine come comfort comic common company concert conduct
  confirm congress connect consider control convince cook cool copper copy
  coral core corn correct cost cotton couch country couple course cousin
  cover coyote crack cradle craft cram crane crash crater crawl crazy
  cream credit creek crew cricket crime crisp critic crop cross crouch
  crowd crucial cruel cruise crumble crunch crush cry crystal cube culture
  cup cupboard curious current curtain curve cushion custom cute cycle
  dad damage damp dance danger daring dash daughter dawn day deal debate
  debris decade december decide decline decorate decrease deer defense
  define defy degree delay deliver demand demise denial dentist deny depart
  depend deposit depth deputy derive describe desert design desk despair
  destroy detail detect develop device devote diagram dial diamond diary
  dice diesel diet differ digital dignity dilemma dinner dinosaur direct
  dirt disagree discover disease dish dismiss disorder display distance
  divert divide divorce dizzy doctor document dog doll dolphin domain
  donate donkey donor door dose double dove draft dragon drama drastic
  draw dream dress drift drill drink drip drive drop drum dry duck dumb
  dune during dust dutch duty dwarf dynamic eager eagle early earn earth
  easily east easy echo ecology economy edge edit educate effort egg eight
  either elbow elder electric elegant element elephant elevator elite else
  embark embody embrace emerge emotion employ empower empty enable enact
  end endless endorse enemy energy enforce engage engine enhance enjoy
  enlist enough enrich enroll ensure enter entire entry envelope episode
  equal equip era erase erode erosion error erupt escape essay essence
  estate eternal ethics evidence evil evoke evolve exact example excess
  exchange excite exclude excuse execute exercise exhaust exhibit exile
  exist exit exotic expand expect expire explain expose express extend extra
  eye eyebrow fabric face faculty fade faint faith fall false fame family
  famous fan fancy fantasy farm fashion fat fatal father fatigue fault
  favorite feature february federal fee feed feel female fence festival
  fetch fever few fiber fiction field figure file film filter final find
  fine finger finish fire firm first fiscal fish fit fitness fix flag flame
  flash flat flavor flee flight flip float flock floor flower fluid flush
  fly foam focus fog foil fold follow food foot force forest forget fork
  fortune forum forward fossil foster found fox fragile frame frequent
  fresh friend fringe frog front frost frown frozen fruit fuel fun funny
  furnace fury future gadget gain galaxy gallery game gap garage garbage
  garden garlic garment gas gasp gate gather gauge gaze general genius
  genre gentle genuine gesture ghost giant gift giggle ginger giraffe
  girl give glad glance glare glass glide glimpse globe gloom glory glove
  glow glue goat goddess gold good goose gorilla gospel gossip govern gown
  grab grace grain grant grape grass gravity great green grid grief grit
  grocery group grow grunt guard guess guide guilt guitar gun gym habit
  hair half hammer hamster hand happy harbor hard harsh harvest hat have
  hawk hazard head health heart heavy hedgehog height hello helmet help hen
  hero hidden high hill hint hip hire history hobby hockey hold hole holiday
  hollow home honey hood hope horn horror horse hospital host hotel hour
  hover hub huge human humble humor hundred hungry hunt hurdle hurry hurt
  husband hybrid ice icon idea identify idle ignore ill illegal illness
  image imitate immense immune impact impose improve impulse inch include
  income increase index indicate indoor industry infant inflict inform
  inhale inherit initial inject injury inmate inner innocent input inquiry
  insane insect inside inspire install intact interest into invest invite
  involve iron island isolate issue item ivory jacket jaguar jar jazz
  jealous jeans jelly jewel job join joke journey joy judge juice jump
  jungle junior junk just kangaroo keen keep ketchup key kick kid kidney
  kind kingdom kiss kit kitchen kite kitten kiwi knee knife knock know
  lab label labor ladder lady lake lamp language laptop large later latin
  laugh laundry lava law lawn lawsuit layer lazy leader leaf learn leave
  lecture left leg legal legend leisure lemon lend length lens leopard
  lesson letter level liar liberty library license life lift light like
  limb limit link lion liquid list little live lizard load loan lobster
  local lock logic lonely long loop lottery loud lounge love loyal lucky
  luggage lumber lunar lunch luxury lyrics machine mad magic magnet maid
  mail main major make mammal man manage mandate mango mansion manual maple
  marble march margin marine market marriage mask mass master match material
  math matrix matter maximum maze meadow mean measure meat mechanic medal
  media melody melt member memory mention menu mercy merge merit merry mesh
  message metal method middle midnight milk million mimic mind minimum minor
  minute miracle mirror misery miss mistake mix mixed mixture mobile model
  modify mom moment monitor monkey monster month moon moral more morning
  mosquito mother motion motor mountain mouse move movie much muffin mule
  multiply muscle museum mushroom music must mutual myself mystery myth
  naive name napkin narrow nasty nation nature near neck need negative
  neglect neither nephew nerve nest net network neutral never news next
  nice night noble noise nominee noodle normal north nose notable note
  nothing notice novel now nuclear number nurse nut oak obey object oblige
  obscure observe obtain obvious occur ocean october odor off offer office
  often oil okay old olive olympic omit once one onion online only open
  opera opinion oppose option orange orbit orchard order ordinary organ
  orient original orphan ostrich other outdoor outer output outside oval
  oven over own owner oxygen oyster ozone pact paddle page pair palace palm
  panda panel panic panther paper parade parent park parrot party pass patch
  path patient patrol pattern pause pave payment peace peanut pear peasant
  pelican pen penalty pencil people pepper perfect permit person pet phone
  photo phrase physical piano picnic picture piece pig pigeon pill pilot
  pink pioneer pipe pistol pitch pizza place planet plastic plate play
  please pledge pluck plug plunge poem poet point polar pole police pond
  pony pool popular portion position possible post potato pottery poverty
  powder power practice praise predict prefer prepare present pretty prevent
  price pride primary print priority prison private prize problem process
  produce profit program project promote proof property prosper protect
  proud provide public pudding pull pulp pulse pumpkin punch pupil puppy
  purchase purity purpose purse push put puzzle pyramid quality quantum
  quarter question quick quit quiz quote rabbit raccoon race rack radar
  radio rail rain raise rally ramp ranch random range rapid rare rate
  rather raven raw razor ready real reason rebel rebuild recall receive
  recipe record recycle reduce reflect reform refuse region regret regular
  reject relax release relief rely remain remember remind remove render
  renew rent reopen repair repeat replace report require rescue resemble
  resist resource response result retire retreat return reunion reveal
  review reward rhythm rib ribbon rice rich ride ridge rifle right rigid
  ring riot ripple risk ritual rival river road roast robot robust rocket
  romance roof rookie room rose rotate rough round route royal rubber rude
  rug rule run runway rural sad saddle sadness safe sail salad salmon salon
  salt salute same sample sand satisfy satoshi sauce sausage save say scale
  scan scare scatter scene scheme school science scissors scorpion scout
  scrap screen script scrub sea search season seat second secret section
  security seed seek segment select sell seminar senior sense sentence
  series service session settle setup seven shadow shaft shallow share
  shed shell sheriff shield shift shine ship shiver shock shoe shoot shop
  short shoulder shove shrimp shrug shuffle shy sibling sick side siege
  sight sign silent silk silly silver similar simple since sing siren
  sister situate six size skate sketch ski skill skin skirt skull slab
  slam sleep slender slice slide slight slim slogan slot slow slush small
  smart smile smoke smooth snack snake snap sniff snow soap soccer social
  sock soda soft solar soldier solid solution solve someone song soon
  sorry sort soul sound soup source south space spare spatial spawn speak
  special speed spell spend sphere spice spider spike spin spirit split
  spoil sponsor spoon sport spot spray spread spring spy square squeeze
  squirrel stable stadium staff stage stairs stamp stand start state stay
  steak steel stem step stereo stick still sting stock stomach stone stool
  story stove strategy street strike strong struggle student stuff stumble
  style subject submit subway success such sudden suffer sugar suggest suit
  summer sun sunny sunset super supply supreme sure surface surge surprise
  surround survey suspect sustain swallow swamp swap swarm swear sweet
  swift swim swing switch sword symbol symptom syrup system table tackle
  tag tail talent talk tank tape target task taste tattoo taxi teach team
  tell ten tenant tennis tent term test text thank that theme then theory
  there they thing this thought three thrive throw thumb thunder ticket tide
  tiger tilt timber time tiny tip tired tissue title toast tobacco today
  toddler toe together toilet token tomato tomorrow tone tongue tonight
  tool tooth top topic topple torch tornado tortoise toss total tourist
  toward tower town toy track trade traffic tragic train transfer trap
  trash travel tray treat tree trend trial tribe trick trigger trim trip
  trophy trouble truck true truly trumpet trust truth try tube tuition
  tumble tuna tunnel turkey turn turtle twelve twenty twice twin twist two
  type typical ugly umbrella unable unaware uncle uncover under undo unfair
  unfold unhappy uniform unique unit universe unknown unlock until unusual
  unveil update upgrade uphold upon upper upset urban urge usage use used
  useful useless usual utility vacant vacuum vague valid valley valve van
  vanish vapor various vast vault vehicle velvet vendor venture venue verb
  verify version very vessel veteran viable vibrant vicious victory video
  view village vintage violin virtual virus visa visit visual vital vivid
  vocal voice void volcano volume vote voyage wage wagon wait walk wall
  walnut want warfare warm warrior wash wasp waste water wave way wealth
  weapon wear weasel weather web wedding weekend weird welcome west wet
  whale what wheat wheel when where whip whisper wide width wife wild will
  win window wine wing wink winner winter wire wisdom wise wish witness
  wolf woman wonder wood wool word work world worry worth wrap wreck wrestle
  wrist write wrong yard year yellow you young youth zebra zero zone zoo
)

declare -A bip39_wordlist_reverse
declare -i i
for ((i=0; i<${#bip39_wordlist[@]}; i++))
do bip39_wordlist_reverse[${bip39_wordlist[$i]}]=$((i+1))
done

check-mnemonic()
  if [[ $# =~ ^(12|15|18|21|24)$ ]]
  then
    local word
    for word
    do ((${bip39_wordlist_reverse[$word]})) || return 1
    done
    create-mnemonic $(
      {
        echo '16o0'
	for word
	do echo ${bip39_wordlist_reverse[$word]}
	done | sed -e 's/.*/2048*& 1-+/'
	echo 2 $(($#*11/33))^ 0k/ p
      } |
      dc |
      { read -r; printf "%$(($#*11*32/33/4))s" $REPLY; } |
      sed 's/ /0/g'
    ) |
    grep -q " ${@: -1}$" || return 2
  else return 3;
  fi

complete -W "${bip39_wordlist[*]}" mnemonic-to-seed
function mnemonic-to-seed() {
  local OPTIND 
  if getopts hbpP o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-USAGE_3
	${FUNCNAME[0]} -h
	${FUNCNAME[@]} [-p|-P] [-b] word ...
	USAGE_3
        ;;
      b) ${FUNCNAME[0]} "$@" |xxd -p -r ;;
      p)
	read -p "Passphrase: "
	BIP39_PASSPHRASE="$REPLY" ${FUNCNAME[0]} "$@"
	;;
      P)
	local passphrase
	read -p "Passphrase:" -s passphrase
	read -p "Confirm passphrase:" -s
	if [[ "$REPLY" = "$passphrase" ]]
	then BIP39_PASSPHRASE=$passphrase $FUNCNAME "$@"
	else echo "passphrase input error" >&2; return 3;
	fi
	;;
    esac
  else
    check-mnemonic "$@"
    case "$?" in
      1) echo "WARNING: unreckognized word in mnemonic." >&2 ;;&
      2) echo "WARNING: wrong mnemonic checksum."        >&2 ;;&
      3) echo "WARNING: unexpected number of words."     >&2 ;;&
      *) pbkdf2 sha512 "$*" "mnemonic$BIP39_PASSPHRASE" 2048 ;;
    esac
  fi
}

function create-mnemonic() {
  local OPTIND OPTARG o
  if getopts h o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-USAGE
	${FUNCNAME[@]} -h
	${FUNCNAME[@]} entropy-size
	USAGE
        ;;
    esac
  elif (( ${#bip39_wordlist[@]} != 2048 ))
  then
    1>&2 echo unexpected number of words in wordlist array
    return 2
  elif [[ $1 =~ ^(128|160|192|224|256)$ ]]
  then $FUNCNAME $(openssl rand -hex $(($1/8)))
  elif [[ "$1" =~ ^([[:xdigit:]]{2}){16,32}$ ]]
  then
    local hexnoise="${1^^}"
    local -i ENT=${#hexnoise}*4 #bits
    if ((ENT % 32))
    then
      1>&2 echo entropy must be a multiple of 32, yet it is $ENT
      return 2
    fi
    { 
      # "A checksum is generated by taking the first <pre>ENT / 32</pre> bits
      # of its SHA256 hash"
      local -i CS=$ENT/32
      local -i MS=$(( (ENT+CS)/11 )) #bits
      #1>&2 echo $ENT $CS $MS
      echo "$MS 1- sn16doi"
      echo "$hexnoise 2 $CS^*"
      echo -n "$hexnoise" |
      xxd -r -p |
      openssl dgst -sha256 -binary |
      head -c1 |
      xxd -p -u
      echo "0k 2 8 $CS -^/+"
      echo "[800 ~r ln1-dsn0<x]dsxx Aof"
    } |
    dc |
    while read -r
    do echo ${bip39_wordlist[REPLY]}
    done |
    {
      mapfile -t
      echo "${MAPFILE[*]}"
    }
  elif (($# == 0))
  then $FUNCNAME 160
  else
    1>&2 echo parameters have insufficient entropy or wrong format
    return 4
  fi
}








#FUNCTIONS

#Load bitcoin functions into shell.
#. ./bitcoin.sh
#. ./bip-0039.sh
#. ./base58.sh  needs to be above bip-0032
#. ./bip-0032.sh
#. ./bech32.sh
#. ./bip-0173.sh






#IMPORTS

#IMPORT ./bitcoin.sh

#!/usr/bin/env bash
# Various bash bitcoin tools
#
# This script uses GNU tools.  It is therefore not guaranted to work on a POSIX
# system.
#
# Requirements are detailed in the accompanying README file.
#
# Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#. base58.sh

hash160() {
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary
}

ser256() {
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{64})$ ]]
  then xxd -p -r <<<"${BASH_REMATCH[2]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{,63})$ ]]
  then ${FUNCNAME[0]} "0x0${BASH_REMATCH[2]}"
  else return 1
  fi
}

bitcoinAddress() {
  local OPTIND o
  if getopts ht o
  then shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE_bitcoinAddress
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} PUBLIC_POINT
	${FUNCNAME[0]} WIF_PRIVATE_KEY
	END_USAGE_bitcoinAddress
        ;;
      t) P2PKH_PREFIX="\x6F" ${FUNCNAME[0]} "$@" ;;
    esac
  elif [[ "$1" =~ ^0([23]([[:xdigit:]]{2}){32}|4([[:xdigit:]]{2}){64})$ ]]
  then
    {
      printf %b "${P2PKH_PREFIX:-\x00}"
      echo "$1" | xxd -p -r | hash160
    } | base58 -c
  elif [[ "$1" =~ ^[5KL] ]] && base58 -v "$1"
  then
    base58 -x "$1" |
    {
      read -r
      if [[ "$REPLY" =~ ^(80|EF)([[:xdigit:]]{64})(01)?([[:xdigit:]]{8})$ ]]
      then
	local point exponent="${BASH_REMATCH[2]^^}"
        if test -n "${BASH_REMATCH[3]}"
        then point="$(echo "${secp256k1_dc}" | dc -e "lG16doi$exponent lMx lCx[0]Pp")"
        else point="$(echo "${secp256k1_dc}" | dc -e "lG16doi$exponent lMx lUxP" |xxd -p -c 130)"
        fi
        if [[ "$REPLY" =~ ^80 ]]
        then ${FUNCNAME[0]} "$point"
        else ${FUNCNAME[0]} -t "$point"
        fi
      else return 2
      fi
    }
  else return 1
  fi
}
        #ORIGINAL: then point="$(dc -f secp256k1.dc -e "lG16doi$exponent lMx lCx[0]Pp")"
        #ORIGINAL: else point="$(dc -f secp256k1.dc -e "lG16doi$exponent lMx lUxP" |xxd -p -c 130)"

newBitcoinKey() {
  local OPTIND o
  if getopts hut o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	${FUNCNAME[0]} -h
	${FUNCNAME[0]} [-t][-u] [PRIVATE_KEY]
        ${FUNCNAME[0]} WIF
	
	The '-h' option displays this message.
	
	PRIVATE_KEY is a natural integer in decimal or hexadecimal, with an
	optional '0x' prefix for hexadecimal.
	
	WIF is a private key in Wallet Import Format.	
	
	The '-u' option will use the uncompressed form of the public key.
        
        If no PRIVATE_KEY is provided, a random one will be generated.
	
	The '-t' option will generate addresses for the test network.
	END_USAGE
        return
        ;;
      u) BITCOIN_PUBLIC_KEY_FORMAT=uncompressed ${FUNCNAME[0]} "$@";;
      t) BITCOIN_NET=TEST ${FUNCNAME[0]} "$@";;
    esac
  elif [[ "$1" =~ ^[1-9][0-9]*$ ]]
  then ${FUNCNAME[0]} "0x$(dc -e "16o$1p")"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,64})$ ]]
  then
    local hex="${BASH_REMATCH[2]^^}"
    {
      if [[ "$BITCOIN_NET" = TEST ]]
      then printf "\xEF"
      else printf "\x80"
      fi
      ser256 "$hex"
      if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" != uncompressed ]]
      then printf "\x01"
      fi
    } | base58 -c

    #ORIGINAL bitcoinAddress  "$(dc -f secp256k1.dc -e "lG16doi$hex lMx lCx[0]Pp")"
    bitcoinAddress  "$(echo "${secp256k1_dc}" | dc -e "lG16doi$hex lMx lCx[0]Pp")"
 
    while ((${#hex} != 64))
    do hex="0$hex"
    done
    
    # see https://stackoverflow.com/questions/48101258/how-to-convert-an-ecdsa-key-to-pem-format
      #ORIGINAL: dc -f secp256k1.dc -e "lG16i$hex lMx l< 2*2^+P"
      #ORIGINAL: dc -f secp256k1.dc -e "lG16i$hex lMx lCx P"
    if [[ "$BITCOIN_PUBLIC_KEY_FORMAT" = uncompressed ]]
    then
      xxd -p -r <<<"30740201010420${hex}A00706052B8104000AA144034200"
      echo "${secp256k1_dc}" | dc -e "lG16i$hex lMx l< 2*2^+P"
    else
      xxd -p -r <<<"30540201010420${hex}A00706052B8104000AA124032200"
      echo "${secp256k1_dc}" | dc -e "lG16i$hex lMx lCx P"
    fi |
    openssl ec -inform der -check

  elif [[ "$1" =~ ^[5KL] ]] && base58 -v "$1"
  then base58 -x "$1" |
    {
      read -r
      if   [[ "$REPLY" =~ ^(80|EF)([[:xdigit:]]{64})(01)?([[:xdigit:]]{8})$ ]]
      then ${FUNCNAME[0]} "0x${BASH_REMATCH[2]}"
      else return 3
      fi
    }
  elif test -z "$1"
  then ${FUNCNAME[0]} "0x$(openssl rand -hex 32)"
  else
    echo unknown key format "$1" >&2
    return 2
  fi
}







#IMPORT ./bip-0039.sh

#!/usr/bin/env bash

ceil() { echo $(( ($1 + $2 + 1)/$2 )); }

pbkdf2_step() {
  local c hash_name="$1" key="$2"
  for c in "${@:3}"
  do printf '%02x\n' "$c"
  done |
  while read -r
  do printf %b "\x$REPLY"
  done |
  openssl dgst -"$hash_name" -hmac "$key" -binary |
  xxd -p -c 1 |
  while read -r
  do echo $((0x$REPLY))
  done
}
function pbkdf2() {
  case "$PBKDF2_METHOD" in
    python)
      local command_str
      printf -v command_str 'import hashlib; print(hashlib.pbkdf2_hmac("%s","%s".encode("utf-8"), "%s".encode("utf-8"), %d).hex())' "$@"
      python -c "$command_str"
      ;;
    *)
      # Translated from https://github.com/bitpay/bitcore/blob/master/packages/bitcore-mnemonic/lib/pbkdf2.js
      # /**
      # * PBKDF2
      # * Credit to: https://github.com/stayradiated/pbkdf2-sha512
      # * Copyright (c) 2014, JP Richardson Copyright (c) 2010-2011 Intalio Pte, All Rights Reserved
      # */
      local hash_name="$1" key_str="$2" salt_str="$3"
      local -ai key salt u t block1
      local -i hLen
      hLen="$(openssl dgst "-$hash_name" -binary <<<"foo" |wc -c)"
      local -i iterations=$4 dkLen=${5:-hLen} i j k destPos hLen len
      
      local -i l=dkLen/hLen
      local -i r=$((dkLen-(l-1)*hLen))

      local c
      for ((i=0; i<${#key_str}; i++))
      do
	printf -v c "%d" "'${key_str:i:1}"
	key+=($c)
      done

      for ((i=0; i<${#salt_str}; i++))
      do
	printf -v c "%d" "'${salt_str:i:1}"
	salt+=($c)
      done

      for ((i=0; i<dKlen; i++)); do dk+=(0); done
      for ((i=0; i< hLen; i++)); do u+=(0); t+=(0); done

      for c in ${salt[@]}; do block1+=($c); done
      for i in {1..4}; do block1+=(0); done

      for ((i=1;i<=l;i++))
      do
	block1[${#salt[@]}+0]=$((i >> 24 & 0xff))
	block1[${#salt[@]}+1]=$((i >> 16 & 0xff))
	block1[${#salt[@]}+2]=$((i >>  8 & 0xff))
	block1[${#salt[@]}+3]=$((i >>  0 & 0xff))
	
	u=($(pbkdf2_step "$hash_name" "$key_str" "${block1[@]}"))
	printf "PBKFD2 iteration %10d/%d" 1 $iterations >&2
	t=(${u[@]})
	for ((j=1; j<iterations; j++))
	do
	  printf "\rPBKFD2 iteration %10d/%d" $((j+1)) $iterations >&2
	  u=($(pbkdf2_step "$hash_name" "$key_str" "${u[@]}"))
	  for ((k=0; k<hLen; k++))
	  do t[k]=$((t[k]^u[k]))
	  done
	done
	echo >&2
	
	destPos=$(( (i-1)*hLen ))
	if ((i == l))
	then len=r
	else len=hLen
	fi
	for ((k=0; k<len; k++))
	do dk[destPos+k]=${t[k]}
	done
	
      done
      printf "%02x" ${dk[@]}
      echo
    ;;
  esac
}







#IMPORT ./base58.sh

#!/usr/bin/env bash

declare base58_chars_str="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
unset dcr; for i in {1..58}; do dcr+="${i}s${base58_chars_str:$i:1}"; done

base58() {
  if (($# == 0))
  then ${FUNCNAME[0]} "$(xxd -p |tr -d '\n')"
  elif
    local OPTIND OPTARG o
    getopts hxdvc o
  then
    shift $((OPTIND - 1))
    case $o in
      d) BASE58_OPERATION=decode-to-binary ${FUNCNAME[0]} "$@";;
      v) BASE58_OPERATION=verify-checksum  ${FUNCNAME[0]} "$@";;
      x) ${FUNCNAME[0]} -d "$@" |
         xxd -p |
         tr -d '\n'
         echo
        ;;
      c) BASE58_USE_CHECKSUM=yes ${FUNCNAME[0]} "$@";;
      h)
        cat <<-END_USAGE
	${FUNCNAME[0]} [options] [hex or base58 string]
	
	options are:
	  -h:	show this help
	  -d:	decode from base58 to binary
	  -x:	decode from base58 to hexadecimal
	  -c:	append checksum
          -v:	verify checksum
	END_USAGE
        return
        ;;
    esac
  elif [[ "$BASE58_OPERATION" = decode-to-binary ]]
  then
    if [[ "$1" =~ ^1+ ]]
    then printf "\x00"; ${FUNCNAME[0]} "${1:1}"
    elif [[ "$1" =~ ^[$base58_chars_str]+$ ]]
    then sed -e "i$dcr 0" -e 's/./ 58*l&+/g' -e "aP" <<<"$1" | dc
    else return 2
    fi
  elif [[ "$BASE58_OPERATION" = verify-checksum ]]
  then
    unset BASE58_OPERATION
    ${FUNCNAME[0]} -d "$1" |
    head -c -4 |
    ${FUNCNAME[0]} -c |
    grep -q "^$1$"
  elif [[ "$BASE58_USE_CHECKSUM" = yes ]]
  then
    unset BASE58_USE_CHECKSUM
    {
       xxd -p -r <<<"$1"
       xxd -p -r <<<"$1" |
       openssl dgst -sha256 -binary |
       openssl dgst -sha256 -binary |
       head -c 4
    } | ${FUNCNAME[0]} 
  elif [[ "$1" =~ ^00 ]]
  then echo -n 1; ${FUNCNAME[0]} "${1:2}"
  elif [[ "$1" =~ ^([[:xdigit:]]{2})+$ ]]
  then sed -e 'i16i0' -e 's/../100*&+/g' -e 'a[3A~rd0<x]dsxx+f' <<<"${1^^}" |
    dc |
    while read -r; do echo -n ${base58_chars_str:$REPLY:1}; done
    echo
  else return 9
  fi
}










#IMPORT ./bip-0032.sh

#if ! test -v base58
#then . base58.sh
#fi

BIP32_MAINNET_PUBLIC_VERSION_CODE=0x0488B21E
BIP32_MAINNET_PRIVATE_VERSION_CODE=0x0488ADE4
BIP32_TESTNET_PUBLIC_VERSION_CODE=0x043587CF
BIP32_TESTNET_PRIVATE_VERSION_CODE=0x04358394

BIP32_XKEY_B58CHCK_FORMAT="[xt](prv|pub)[$base58_chars_str]{1,112}"
BIP32_SOFT_DERIVATION_STEP="/([[:digit:]]+|N)"
BIP32_HARD_DERIVATION_STEP="/[[:digit:]]+h?"
BIP32_SOFT_DERIVATION_PATH="($BIP32_SOFT_DERIVATION_STEP)+"
BIP32_HARD_DERIVATION_PATH="($BIP32_HARD_DERIVATION_STEP)+($BIP32_SOFT_DERIVATION_STEP)*"
BIP32_XKEY_FORMAT="$BIP32_XKEY_B58CHCK_FORMAT($BIP32_SOFT_DERIVATION_PATH|$BIP32_HARD_DERIVATION_PATH)"

isPrivate() ((
  $1 == BIP32_TESTNET_PRIVATE_VERSION_CODE ||
  $1 == BIP32_MAINNET_PRIVATE_VERSION_CODE
))

isPublic() ((
  $1 == BIP32_TESTNET_PUBLIC_VERSION_CODE ||
  $1 == BIP32_MAINNET_PUBLIC_VERSION_CODE
))

fingerprint() {
  xxd -p -r <<<"$1" |
  openssl dgst -sha256 -binary |
  openssl dgst -rmd160 -binary |
  head -c 4 |
  xxd -p -u -c 8
}

debug()
  if [[ "$DEBUG" = yes ]]
  then echo "DEBUG: $@"
  fi >&2


#####################
bip32()
  if
    debug "${FUNCNAME[0]} $@"
    local OPTIND OPTARG o
    getopts hp:s:t o
  then
    shift $((OPTIND - 1))
    case "$o" in
      h) cat <<-END_USAGE
	Usage:
	  $FUNCNAME -h
	  $FUNCNAME [-t]
          $FUNCNAME -s HEX-ENCODED-SEED
	  $FUNCNAME [-p] EXTENDED-KEY
	  $FUNCNAME version depth parent-fingerprint child-number chain-code key
	
	With no argument, $FUNCNAME will generate an extended master key from a
	seed read on standard input.  With the -t option, it will generate an extended
	master key for the test network.
        
	END_USAGE
        ;;
      p)
        if [[ "$OPTARG" =~ ^$BIP32_XKEY_B58CHCK_FORMAT$ ]] && base58 -v "$OPTARG"
        then
	  base58 -x "$OPTARG" |
	  {
	    read
	    local -a args=(
	      "0x${REPLY:0:8}"   # 4 bytes:  version
	      "0x${REPLY:8:2}"   # 1 byte:   depth
	      "0x${REPLY:10:8}"  # 4 bytes:  fingerprint of the parent's key
	      "0x${REPLY:18:8}"  # 4 bytes:  child number
	      "${REPLY:26:64}"   # 32 bytes: chain code
	      "${REPLY:90:66}"   # 33 bytes: public or private key data
	    )
	    if $FUNCNAME "${args[@]}" >/dev/null
	    then echo "${args[@]}"
	    else return $?
	    fi
	  }
        elif [[ "$OPTARG" =~ ^$BIP32_XKEY_FORMAT$ ]]
        then ${FUNCNAME[0]} -p "$(${FUNCNAME[0]} "$OPTARG")"
        else return 2
        fi
        ;;
      s)
         if [[ "$OPTARG" =~ ^([[:xdigit:]]{2})+$ ]]
         then xxd -p -r <<<"$OPTARG" | ${FUNCNAME[0]} "$@"
         else return 135
         fi
         ;;
      t) BITCOIN_NET=TEST $FUNCNAME "$@" ;;
    esac
  elif (($# == 0))
  then
    local -i version=$BIP32_MAINNET_PRIVATE_VERSION_CODE
    if [[ "$BITCOIN_NET" = 'TEST' ]]
    then version=$BIP32_TESTNET_PRIVATE_VERSION_CODE
    fi
    openssl dgst -sha512 -hmac "Bitcoin seed" -binary |
    xxd -u -p -c 64 |
    {
      read
      $FUNCNAME $version 0 0 0 "${REPLY:64:64}" "00${REPLY:0:64}"
    }
  elif (( $# == 6 ))
  then
    local -i version=$1 depth=$2 fingerprint=$3 childnumber=$4
    local chaincode=$5 key=$6
    >&2 echo version=$1 depth=$2 fingerprint=$3 childnumber=$4 chaincode=$5 key=$6
    >&2 echo BIP32_MAINNET_PUBLIC_VERSION_CODE = $BIP32_MAINNET_PUBLIC_VERSION_CODE , BIP32_MAINNET_PRIVATE_VERSION_CODE = $BIP32_MAINNET_PRIVATE_VERSION_CODE
    if ((
      version != BIP32_TESTNET_PRIVATE_VERSION_CODE &&
      version != BIP32_MAINNET_PRIVATE_VERSION_CODE &&
      version != BIP32_TESTNET_PUBLIC_VERSION_CODE  &&
      version != BIP32_MAINNET_PUBLIC_VERSION_CODE
    ))
    then return 1
    elif ((depth < 0 || depth > 255))
    then return 2
    elif ((fingerprint < 0 || fingerprint > 0xffffffff))
    then return 3
    elif ((childnumber < 0 || childnumber > 0xffffffff))
    then return 4
    elif [[ ! "$chaincode" =~ ^[[:xdigit:]]{64}$ ]]
    then return 5
    elif [[ ! "$key"       =~ ^[[:xdigit:]]{66}$ ]]
    then return 6
    elif isPublic  $version && [[ "$key" =~ ^00    ]]
    then return 7
    elif isPrivate $version && [[ "$key" =~ ^0[23] ]]
    then return 8
    # TODO: check that the point is on the curve?
    else
      printf "%08x%02x%08x%08x%s%s" "$@" |
      xxd -p -r |
      base58 -c
    fi
  elif [[ "$1" =~ ^$BIP32_XKEY_B58CHCK_FORMAT$ ]] && base58 -v "$1"
  then $FUNCNAME -p "$1" >/dev/null && echo $1
  elif [[ "$1" =~ ^$BIP32_XKEY_B58CHCK_FORMAT/N$ ]]
  then
    $FUNCNAME -p "${1::-2}" |
    {
      local -i version depth pfp index
      local    cc key
      read version depth pfp index cc key
      case $version in
         $((BIP32_TESTNET_PUBLIC_VERSION_CODE)))
           ;;
         $((BIP32_MAINNET_PUBLIC_VERSION_CODE)))
           ;;
         $((BIP32_MAINNET_PRIVATE_VERSION_CODE)))
           version=$BIP32_MAINNET_PUBLIC_VERSION_CODE;;&
         $((BIP32_TESTNET_PRIVATE_VERSION_CODE)))
           version=$BIP32_TESTNET_PUBLIC_VERSION_CODE;;&
         *) key="$(echo "${secp256k1_dc}" | dc -e "16doilG${key^^}lMxlEx")" || return 100
      esac
      $FUNCNAME $version $depth $pfp $index $cc $key
    }
  elif [[ "$1" =~ ^$BIP32_XKEY_B58CHCK_FORMAT/([[:digit:]]+)h$ ]]
  then $FUNCNAME "${1%/*}/$((${BASH_REMATCH[2]} + (1<<31)))" 
  elif [[ "$1" =~ ^$BIP32_XKEY_B58CHCK_FORMAT/[[:digit:]]+$ ]]
  then
    local xkey="${1%/*}" 
    local -i childIndex=${1##*/}
    $FUNCNAME -p "$xkey" |
    {
      local -i version depth pfp index    fp
      local    cc key
      read version depth pfp index cc key
      
      if isPrivate $version
      then
        CKDpriv "$key" "$cc" $childIndex |
        {
           local ki ci
           read ki ci
	   fp="0x$(fingerprint "$(echo "${secp256k1_dc}" | dc -e "16doilG${key^^}lMxlEx")")"
           $FUNCNAME $version $((depth+1)) $fp $childIndex $ci $ki
        }
      elif isPublic $version
      then
        CKDpub "$key" "$cc" $childIndex |
        {
           local Ki ci
           read Ki ci
	   fp="0x$(fingerprint "$key")"
           $FUNCNAME $version $((depth+1)) $fp $childIndex $ci $Ki
        }
      else return 255  # should never happen
      fi
    } 
  elif [[ "$1" =~ ^$BIP32_XKEY_FORMAT$ ]]
  then $FUNCNAME "$($FUNCNAME "${1%/*}")/${1##*/}"
  elif [[ "$1" =~ ^($BIP32_SOFT_DERIVATION_PATH|$BIP32_HARD_DERIVATION_PATH)$ ]]
  then ${FUNCNAME[0]} "$(${FUNCNAME[0]})$1"
  else return 1
  fi

CKDpub()
  if [[ ! "$1" =~ ^0[23]([[:xdigit:]]{2}){32}$ ]]
  then return 1
  elif [[ ! "$2" =~ ^([[:xdigit:]]{2}){32}$ ]]
  then return 2
  elif local Kpar="$1" cpar="$2"
       local -i i=$3
    ((i < 0 || i > 1<<32))
  then return 3
  else
    if (( i >= (1 << 31) ))
    then return 4
    else
      {
	xxd -p -r <<<"$Kpar"
	ser32 $i
      } |
      openssl dgst -sha512 -mac hmac -macopt hexkey:$cpar -binary |
      xxd -p -u -c 64 |
      {
	read
	local Ki="$(echo "${secp256k1_dc}" | dc -e "16doi${REPLY:0:64} ${Kpar^^}lAxlEx")"
	local ci="${REPLY:64:64}"
	echo $Ki $ci
      }
    fi
  fi

CKDpriv()
  if [[ ! "$1" =~ ^00([[:xdigit:]]{2}){32}$ ]]
  then return 1
  elif [[ ! "$2" =~ ^([[:xdigit:]]{2}){32}$ ]]
  then return 2
  elif local kpar="${1:2}" cpar="$2"
       local -i i=$3
    ((i < 0 || i > 1<<32))
  then return 3
  else
    if (( i >= (1 << 31) ))
    then
      printf "\x00"
      ser256 "0x$kpar"
      ser32 $i
    else
      echo "${secp256k1_dc}" | dc -e "16doilG${kpar^^}lMxlEx" |xxd -p -r
      ser32 $i
    fi |
    openssl dgst -sha512 -mac hmac -macopt hexkey:$cpar -binary |
    xxd -p -u -c 64 |
    {
      read
      local ki ci
      ki="$(echo "${secp256k1_dc}" | dc -e "16doi${kpar^^} ${REPLY:0:64}+ln%p")"
      ki="00$(ser256 "$ki" |xxd -p -c 64)"
      ci="${REPLY:64:64}"
      if [[ ! "$ki" =~ ^[[:xdigit:]]{66}$ ]]
      then echo "could not produce private key" >&2
        return 105
      else echo $ki $ci
      fi
    }
  fi

ser32()
  if
    local -i i=$1
    ((i >= 0 && i < 1<<32)) 
  then printf "%08x" $i |xxd -p -r
  else
    1>&2 echo index out of range
    return 1
  fi

ser256()
  if   [[ "$1" =~ ^(0x)?([[:xdigit:]]{64})$ ]]
  then xxd -p -r <<<"${BASH_REMATCH[2]}"
  elif [[ "$1" =~ ^(0x)?([[:xdigit:]]{1,63})$ ]]
  then $FUNCNAME "0x0${BASH_REMATCH[2]}"
  else return 1
  fi














#IMPORT ./bech32.sh

#!/usr/env/bin bash

# Translated from javascript.
#
# Original code link:
# https://github.com/sipa/bech32/blob/master/ref/javascript/bech32.js

# Copyright and permission notice in original file :
# 
# // Copyright (c) 2017, 2021 Pieter Wuille
# //
# // Permission is hereby granted, free of charge, to any person obtaining a copy
# // of this software and associated documentation files (the "Software"), to deal
# // in the Software without restriction, including without limitation the rights
# // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# // copies of the Software, and to permit persons to whom the Software is
# // furnished to do so, subject to the following conditions:
# //
# // The above copyright notice and this permission notice shall be included in
# // all copies or substantial portions of the Software.
# //
# // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# // THE SOFTWARE.

declare BECH32_CHARSET="qpzry9x8gf2tvdw0s3jn54khce6mua7l"
declare -A BECH32_CHARSET_REVERSE
for i in {0..31}
do BECH32_CHARSET_REVERSE[${BECH32_CHARSET:$i:1}]=$((i))
done


BECH32_CONST=1

polymod() {
  local -ai generator=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  local -i chk=1 value
  for value
  do
    local -i top i
    
    ((top = chk >> 25, chk = (chk & 0x1ffffff) << 5 ^ value))
    
    for i in 0 1 2 3 4
    do (( ((top >> i) & 1) && (chk^=${generator[i]}) ))
    done
  done
  echo $chk
}

hrpExpand() {
  local -i p ord
  for ((p=0; p < ${#1}; ++p))
  do printf -v ord "%d" "'${1:$p:1}"
    echo $(( ord >> 5 ))
  done
  echo 0
  for ((p=0; p < ${#1}; ++p))
  do printf -v ord "%d" "'${1:$p:1}"
    echo $(( ord & 31 ))
  done
}

verifyChecksum() {
  local hrp="$1"
  shift
  local -i pmod="$(polymod $(hrpExpand "$hrp") "$@")"
  (( pmod == $BECH32_CONST ))
}

createChecksum() {
  local hrp="$1"
  shift
  local -i p mod=$(($(polymod $(hrpExpand "$hrp") "$@" 0 0 0 0 0 0) ^ $BECH32_CONST))
  for p in 0 1 2 3 4 5
  do echo $(( (mod >> 5 * (5 - p)) & 31 ))
  done
}

bech32_encode()
  if
    local OPTIND o
    getopts m o
  then
    shift $((OPTIND - 1))
    BECH32_CONST=0x2bc830a3 $FUNCNAME "$@"
  else
    local hrp=$1 i
    shift
    echo -n "${hrp}1"
    {
      for i; do echo $i; done
      createChecksum "$hrp" "$@"
    } |
    while read; do echo -n ${BECH32_CHARSET:$REPLY:1}; done
    echo
  fi

bech32_decode()
  if
    local OPTIND o
    getopts m o
  then
    shift $((OPTIND - 1))
    BECH32_CONST=0x2bc830a3 $FUNCNAME "$@"
  else
    local bechString=$1
    local -i p has_lower=0 has_upper=0 ord

    for ((p=0;p<${#bechString};++p))
    do
      printf -v ord "%d" "'${bechString:$p:1}"
      if   ((ord <  33 || ord >  126))
      then return 1
      elif ((ord >= 97 && ord <= 122))
      then has_lower=1
      elif ((ord >= 65 && ord <= 90))
      then has_upper=1
      fi
    done
    if ((has_upper && has_lower))
    then return 2 # mixed case
    elif bechString="${bechString,,}"
      ((${#bechString} > 90))
    then return 3 # string is too long
    elif [[ ! "$bechString" =~ 1 ]]
    then return 4 # no separator
    elif
      local hrp="${bechString%1*}"
      test -z $hrp
    then return 5 # no human readable part
    elif local data="${bechString##*1}"
      ((${#data} < 6))
    then return 6 # data is too short
    else
      for ((p=0;p<${#data};++p))
      do echo "${BECH32_CHARSET_REVERSE[${data:$p:1}]}"
      done |
      {
	mapfile -t
	if verifyChecksum "$hrp" "${MAPFILE[@]}"
	then
	  echo $hrp
	  for p in "${MAPFILE[@]::${#MAPFILE[@]}-6}"
	  do echo $p
	  done
	else return 8
	fi
      }
    fi
  fi








#IMPORT ./bip-0173.sh

#!/usr/bin/env bash

#. bech32.sh

p2wpkh() { segwitAddress -p "$1"; }

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
    [[ ! "$witness_program" =~ ^([[:xdigit:]]{2})+$ ]]
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








#MAIN

echo -e "Use this script only after you understand the instructions provided here:
https://github.com/petjal/bitcoin-bash-tools/blob/pjdev/VITAL_INFORMATION"

#ENTROPY
echo
echo "Gathering and testing entropy..."
#This find command fails in github action workspace, that's ok.
#If you don't get enough entropy, increase this "head" count from 100 to 1000 or 10000, but the script will take that much longer.
find ~ -type f 2> /dev/null | head -n 100 | xargs cat > /dev/null 2>&1
#test entropy
kernel_entropy_avail=$(cat /proc/sys/kernel/random/entropy_avail) # less than 100-200, you have a problem
echo "kernel_entropy_avail: $kernel_entropy_avail (greater than 100 is good)"

if [[ "$kernel_entropy_avail" -lt "200" ]] ; then echo "ERROR: kernel entropy_avail $kernel_entropy_avail less than 100, too low, sorry, cannot proceed." ; exit 1 ; fi
#Entropy = 1.000000 bits per bit.
#entropy_test_val=$(head -c 1M /dev/urandom > /tmp/out ; ent -b /tmp/out | grep Entropy | cut -d ' ' -f 3)
entropy_test_val=$(head -c 1M /dev/urandom | ent -b /tmp/out | grep Entropy | cut -d ' ' -f 3)
echo "entropy test value: $entropy_test_val (1.000 is great)"
if [[ "$entropy_test_val" < "0.9000" ]] ; then echo "ERROR: entropy $entropy_test_val less than 0.9, too low, sorry, cannot proceed." ; fi
echo


#echo "generating new sequence of 12 secret words..."
my_new_secret_words=$(create-mnemonic 128)  # 128 = 12 words, 256 = 24 words of entropy

check-mnemonic "$my_new_secret_words" # ; echo $?  returns 3
echo "HERE IS YOUR BITCOIN SECRET SEED PHRASE:"
echo $my_new_secret_words
echo

echo "This next step will take up to two minutes or more on a low-powered computer such as a raspberry pi..."

root_seed=$(mnemonic-to-seed "$my_new_secret_words" 2> /dev/null)  # takes a very long time due to pbkdf2; 128 bytes
echo "cksum root_seed = $(echo -n "$root_seed" | cksum)"
m=$(bip32 -s "$root_seed")  # private key
echo "m = $m"
private_key_details=$(bip32 -p "$m")
echo "private_key_details = $private_key_details"
bip32 "$m/N" ; echo $? # new public key from private key
M=$(bip32 "$m/N") # new public key from private
echo "M (new public key) = $M"
public_key_details=$(bip32 -p "$M")
echo "public_key_details = $public_key_details"
p=$(echo "$public_key_details" | cut -d ' ' -f 6)
echo "p = $p"
echo


echo "HERE IS YOUR PUBLIC BITCOIN ADDRESS:"
segwitAddress -p $p
echo


