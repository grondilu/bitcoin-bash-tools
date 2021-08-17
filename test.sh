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

for v in "${correct_bech32[@]}"
do bech32_verify "$v" || echo "$v is seen as incorrect (error code $?) and it shouldn't"
done

for v in "${incorrect_bech32[@]}"
do bech32_verify "$v" && echo "$v is seen as correct while it shouldn't"
done

:
