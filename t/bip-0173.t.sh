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

declare -A correct_segwit_addresses=(
  BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4 0014751e76e8199196d454941c45d1b3a323f1433bd6
  tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7 00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262
  bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx 5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6
  BC1SW50QA3JX3S 6002751e
  bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj 5210751e76e8199196d454941c45d1b3a323
  tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy 0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433
)

declare -a incorrect_segwit_addresses=(
  tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty
  bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5
  BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2
  bc1rw5uspcuh
  bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90
  BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P
  tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7
  bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du
  tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv
  bc1gmk9yu
)

echo 1..$((${#correct_bech32[@]} + ${#incorrect_bech32[@]} + ${#correct_segwit_addresses[@]} + ${#incorrect_segwit_addresses[@]}))
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

for k in "${!correct_segwit_addresses[@]}"
do
  ((t++))
  bech32_verify "$k" && echo "ok $t - $k is a valid bech32"
done

echo segwit
for k in "${incorrect_segwit_addresses[@]}"
do
  ((t++))
  if ! bech32_verify "$k"
  then echo "ok $t - error in $k is detected"
  else echo "not ok $t - failed to detect error in $k"
  fi
done
