json="t/base58_encode_decode.json"

. base58.sh

echo 1..$(jq length < $json)
declare -i t=0
jq -r ".[]|\"\(.[0]) \(.[1])\"" < $json |
while read a b
do
  ((t++))
  declare c=$(xxd -p -r <<<$a |encodeBase58)
  if [[ "$c" = "$b" ]]
  then echo "ok $t - $a → $b"
  else echo "not ok $t - $a → $c instead of $b"
  fi
done
