json="t/base58_encode_decode.json"

. bx.sh

echo 1..$(jq length < $json)
declare -i t=0
jq -r ".[]|\"\(.[0]) \(.[1])\"" < $json |
while read a b
do
  ((t++))
  declare c="$(bx base58-encode "$a")"
  if [[ "$c" = "$b" ]]
  then echo "ok $t - $a → $b"
  else echo "not ok $t - $a → $c instead of $b"
  fi
done
