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
do
  echo -n testing $v...
  bech32_verify "$v" && echo ok || echo "seen as incorrect (error code $?) and it shouldn't"
done

for v in "${incorrect_bech32[@]}"
do
  echo -n testing $v...
  ! bech32_verify "$v" && echo ok || echo "seen as correct while it shouldn't"
done

xxd -p -r <<<751e76e8199196d454941c45d1b3a323f1433bd6 |
segwit_encode bc 0 |
grep -q -i "^bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4$" ||
echo segwit address encoding failed for pkh 751e76e8199196d454941c45d1b3a323f1433bd6

TEST_VECTORS_URL="https://raw.githubusercontent.com/trezor/python-mnemonic/master/vectors.json"
wget -O - -q "$TEST_VECTORS_URL" |
jq -r '
". bip-0039.sh",
( .english[]|"bip39 \"\(.[0])\" |
fmt -w1000 |
grep -q \"\(.[1])\" || 1>&2 echo wrong mnemonic produced for \(.[0])" )
' |bash

