#!/bin/bash
# 
# This is free and unencumbered software released into the public domain.
# 
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
# 
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
#
# requires bash 4+ for associative arrays
# requires the mongodb standard client
# requires openssl
# requires wget (could be replaced by curl if necessary)
#

if [[ "$REQUEST_METHOD" = "POST" ]] && [[ "$CONTENT_LENGTH" -gt 0 ]]
then
    #################################################################################
    #
    # server part
    #
    #################################################################################

    read -N $CONTENT_LENGTH POST_DATA <&0

    declare -A data
    while IFS='=' read -r -d '&' key value
    do [[ $key ]] && data[$key]="$value"
    done <<<"$POST_DATA&"

    echo "Content-type:	text/plain"
    echo

    if [[ "${data[order]}" =~ '^{ ref: [a-fA-F0-9]{4}, time: [0-9]+, bid: { .* }, ask: { .* } }$' ]]
    then echo "wrong order (not JSON or wrong format)"
    elif ! openssl dgst -sha1 -verify <(echo "${data[pubkey]}") -signature <(base64 -d <<< "${data[signature]}") <<<"${data[order]}" 2>&1 >&-
    then echo wrong signature
    else 
	# can't put carriage returns in a javascript string
	pubkey="${data[pubkey]//$'\n'/\\n}"

	mongo s0.barwen.ch/test <<-EOF
	var order = ${data[order]}

	if (typeof(order.ref) != "string" || ! order.ref.match(/[a-f0-9]{4}/i)) {
	    print("wrong type or format for reference")
	} else if (typeof(order.time) != "number") {
	    print("wrong type for time")
	} else if (typeof(order.ask) != "object") {
	    print("wrong type for ask")
	} else if (typeof(order.bid) != "object") {
	    print("wrong type for bid")
	} else if (typeof(order.bid.name) != "string") {
	    print("wrong type for bid.name")
	} else if (typeof(order.ask.name) != "string") {
	    print("wrong type for ask.name")
	} else if (typeof(order.ask.quantity) != "number" || order.ask.quantity < 0 ) {
	    print("wrong type for ask.quantity")
	} else if (typeof(order.bid.quantity) != "number" || order.bid.quantity < 0 ) {
	    print("wrong type for bid.quantity")
	} else if (db.orders.count({ ref: order.ref, time: order.time }) > 0) {
	    print("order has already been submitted")
	} else if (order.ask.name.match(/^create$/i)) {

	    // request for creation

	    if (db.assets.count( { name: order.bid.name, creator: { '\$ne':  "$pubkey"} } ) > 0) {
		print("this asset belongs to someone else")
	    } else {
		asset = { name: order.bid.name, creator: "$pubkey" }
		nmatch = db.assets.count(asset)

	        if ( nmatch == 0 ) {
		    // the asset doesn't exist
		    db.assets.save( asset )
		} else if (nmatch > 1) {
		    // should not happen
		    print("warning: too many assets matching this name and creator")
		} 

		order.signature = "${data[signature]}"
		order.pubkey = "$pubkey"
		order.bid.done = order.bid.quantity
		order.ask.done = order.ask.quantity
		db.orders.save(order)
		order
	    }

	} else if (order.ask.name.match(/^balance$/i)) {
	     
	     // request for balance

	} else if (order.bid.name.match(/^extern$/i)) {
	     
	     // request for withdrawal

	} else if (order.bid.name.match(/^extern$/i)) {

	     // request for deposit
	     
	} else {
	    print("coudn't parse order")
	}
	EOF

    fi

else
    #################################################################################
    #
    # client part
    #
    #################################################################################

    # server's location
    server=http://localhost/$0

    amountregex='(0|0\.[0-9]+|[1-9][0-9]*\.[0-9]+|[1-9][0-9]*)'
    assetregex='[a-zA-Z][a-zA-Z0-9_]*'
    commandregex="^BUY $amountregex $assetregex SELL $amountregex $assetregex$"

    # client's private key
    # you can also copy paste your PEM key right here
    # (but you'll have to tweak the code further down)
    privkey="$HOME/Private/brokerage.pem"

    if [[ ! "$1" =~ $commandregex ]]
    then echo "wrong command string"  1>&2
    else
	bidden_amount="$(cut -d\  -f 2 <<<$1)"
	bidden_asset="$(cut -d\  -f 3 <<<$1)"
	asked_amount="$(cut -d\  -f 5 <<<$1)"
	asked_asset="$(cut -d\  -f 6 <<<$1)"

	order="$(sed -r 's/\s+/ /g' <<< "{ \
	    ref: \"$(printf "%04x" $RANDOM)\",\
	    time: $(date +%s),\
	    bid: { name: \"$bidden_asset\", quantity: $bidden_amount }, \
	    ask: { name: \"$asked_asset\", quantity: $asked_amount } \
	}")"

	message="order=$order&signature=$(
	openssl dgst -sha1 -sign "$privkey" <<<"$order" |
	base64 -w 0)"
	message+="&pubkey=$(openssl rsa -pubout -in "$privkey")"

	wget -q --no-proxy --post-data "$message" -O - $server

    fi

fi
