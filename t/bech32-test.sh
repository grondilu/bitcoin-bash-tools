. bech32.sh

declare -a correct_bech32=(
	A12UEL5L
	a12uel5l
	an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs
	abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw
	11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j
	split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w
	?1ezyfcl
)
declare -a incorrect_bech32=(
	an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx # overall max length exceeded
	pzry9x0s0muk # No separator character
	1pzry9x0s0muk # Empty HRP
	x1b4n0q5v # Invalid data character
	li1dgmt3 # Too short checksum
	A1G7SGD8 # checksum calculated with uppercase form of HRP
	10a06t8 # empty HRP
	1qzzfhee # empty HRP
)

echo 1..$((${#correct_bech32[@]} + ${#incorrect_bech32[@]}))
declare -i t=0
for v in "${correct_bech32[@]}"
do
  ((t++))
  bech32_verify "$v" && echo "ok $t - '$v' is valid" 
done

for v in "${incorrect_bech32[@]}"
do
  ((t++))
  ! bech32_verify "$v" && echo "ok $t - error in '$v' is detected" 
done
