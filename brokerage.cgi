#!/bin/bash

holder=grondilu
content() { echo -e "Content-type: text/${1:-html}"; echo ; }
title()   { echo "<title>${holder^}'s stock exchange</title>" ; }
image()   { echo "<img src=\"$1\" $2/>" ; }
space()   { echo "<b3>"{,,,} ; }
back()    { echo "<p><a href=$0>back to main page</a></p>" ; }
error()   { echo "<p><b>ERROR:</b> $@</p>" ; back ; }

urldecode() { echo -e "$(sed 'y/+/ /; s/%/\\x/g')" | dos2unix ; }

maintenance() {
    content html
    echo "<p>This site is being maintained.  Please come back later.</p>"
    exit
}

#maintenance

. base58.sh

csv="${0//.cgi/.csv}"
archive="${0//.cgi/.tar}"

bc_key="https://github.com/dirtyfilthy/bc_key"
bc_sign="https://github.com/grondilu/bitcoin-bash-tools"

if [[ "$REQUEST_METHOD" = "POST" ]] && [[ "$CONTENT_LENGTH" -gt 0 ]]
then
    read -n $CONTENT_LENGTH POST_DATA <&0

    post_data() { urldecode <<< "$POST_DATA" ; }
    content html

    pubkey() {
        post_data |
        sed -nr '4s/.*&signature=//; /BEGIN PUBLIC KEY/,/END PUBLIC KEY/p' 
    }
    signature() {
        post_data |
        sed -r '4s/.*&signature=//; 1,3d; /BEGIN PUBLIC KEY/,/END PUBLIC KEY/d' |
        xxd -p -r
    }
    transaction() {
        post_data | sed -nr '1s/^.*tx=// ; 4s/&signature=.*//; 1,4p'
    }
    if 
        echo "Verifying signature... "
        ! openssl dgst -sha256 -verify <(pubkey) -signature <(signature) <(transaction) 2>&1
    then echo "Wrong signature"
	back
    elif 
        from="$(post_data |
        sed -nr 's/.*&signature=//g ; /BEGIN PUBLIC KEY/,/END PUBLIC KEY/p' |
        publicKeyToAddress)"
        echo "<p>Good signature from $from.</p>"

        parse() { post_data | sed -nr "1s/^.*tx=// ; s/&signature=.*// ; 1,4s/^$1:\s+//p" ; }
        id="$(parse id)"

        grep -q "^$id," "$csv"
    then error "This transaction has already been done: <a href=$0?tx_log=html#$id>$id</a>"
    elif
        to="$(parse to)"
        ! checkBitcoinAddress "$to"
    then error "Destination address is not a valid bitcoin address"
    elif
        quantity="$(parse quantity)"
        [[ ! "$quantity" =~ ^[1-9][0-9]*$ ]]
    then error "Submitted quantity is not a valid integer amount."
    elif
        company="$(parse company)"

        owned="$(awk -F, "\$4 == \"$company\" {
        if(\$3==\"$from\") s+=\$5 ; if(\$2==\"$from\") s-=\$5
        } END { print s }" "$csv"
        )"

        [[ "$quantity" > "$owned" ]]
    then error "Address '$from' is not associated to enough shares of company '$company'."
    elif
        post_data |
        grep -q '^confirm=yes'
    then
        echo $id,$from,$to,$company,$quantity >> $csv
        transaction > tmp/"$id"
        signature > tmp/"$id".sha256
        pubkey > tmp/"$from".pem
        tar uf "$archive" tmp/{"$id"{,.sha256},"$from".pem}
        rm tmp/{"$id"{,.sha256},"$from".pem}

        echo "<p>Your transaction has been executed.  You can find it <a href=$0?tx_log=html#$id>here</a>.</p>"
        back
    else
        echo "<p>This address is associated to $owned share(s) of the company '$company'.<br>"
        echo "After execution, there will be $((owned - quantity)) share(s) left.</p>"

        echo "<form action=$0 method=post>
        <input type=hidden name=confirm value=yes>
        <p>This the transaction order :<br>
        <tt><textarea name=tx cols=60 rows=4 readonly=readonly>$(transaction)</textarea></tt></p>
        <p>And this is the signature :<br>
        <tt><textarea name=signature cols=80 rows=12 readonly=readonly>$(signature |xxd -p; pubkey)</textarea></tt></p>
        Press confirmation button to confirm this transaction (this is your last chance to retract !):<br>
        <input type=submit></form>
        "
        back
    fi

elif [[ -z "$QUERY_STRING" ]]
then

    content html
    title
    image bitcoin-factory-small.png height=175
    echo "<h1>${holder^}'s exchange</h1>"
    space

    echo "
    <ul>
    <li><form action=$0 method=get>
    <input type=hidden name=id value="$(printf %x "$RANDOM").$(date +%s)">
    Transfer
    <select name=quantity>" "<option>"{1..10} "</select>
    <select name=company>$(cut -d, -f4 "$csv" | sort -u | sed 's/^/<option>/')</select>
    share(s)<br>
    to<sup>: <input type=text name=to size=34><br>
    <input type=submit>
    </form>

    <li>See full transaction log :
    <a href=$0?tx_log=html>html</a> or
    <a href=$0?tx_log=csv>CSV</a>

    <li>See <a href=$0?asset=list>asset list</a>
    <li><a href=$0?show_source=yes>Show the source of this page</a>

    </ul>
    "

elif 
    eval "${QUERY_STRING//&/ }"
    [[ -n "$show_source" ]]
then
    content plain
    cat "$0"
    
elif
    [[ -n "$asset" ]]
then
    case "${asset,,}" in
        list)
            content html
            echo "<ul>"
            cut -d, -f4 < "$csv" |
            sort -u |
            while read a
            do echo "<li><a href=$0?asset=$a>$a</a>"
            done
            echo "</ul>"

	    back
            ;;
        drdgold|ebay|testshare)
            content plain
            tar xOf "$archive" "$asset.asc"
            ;;
        *)
            content html
            echo "<p>Unknow asset</p>"
            back

            ;;
    esac

elif
    [[ -n "$to" ]]
then
    content html
    if ! checkBitcoinAddress "$to"
    then
        echo "<p>$to is not a bitcoin address (checkBitcoinAddress returned $?)</p>"
        back
    else
        echo -n "
        <form action=$0 method=post>
        You are about to make the following transfer:<br>
        <tt><textarea name=tx cols=60 rows=4 readonly=readonly>$(
        echo "id:           $id"
        echo "quantity:     $quantity"
        echo "company:      $company"
        echo "to:           $to"
        )</textarea></tt><br>
        Please make a signed sha256 digest of this text and put it here, along with the public key<sup><a href=#example>see example</a></sup>:<br>
        <tt><textarea name=signature cols=80 rows=12></textarea></tt><br>
        <input type=submit> (you will be asked for confirmation in the next screen)
        </form>
        $(back)
        <ul>
        <li>Download the two programs required for signing : <a href=$bc_key>Bitcoin key extractor</a> (C language) and <a href=$bc_sign>bitcoin bash tools</a> (bash)</p>
        <li><a name=example>
        Your output should look like this:<tt><xmp>
3045022100eb80fd011a907a6a8325085f44919c2bc40c7222ecbc20d5ef
a853f44b5e62b10220603c5ff482c98c625813f5f14b91f68711fcafe0ad
38ef0149fa431ea0fbbd01
-----BEGIN PUBLIC KEY-----
MIH1MIGuBgcqhkjOPQIBMIGiAgEBMCwGByqGSM49AQECIQD/////////////////
///////////////////+///8LzAGBAEABAEHBEEEeb5mfvncu6xVoGKVzocLBwKb
/NstzijZWfKBWxb4F5hIOtp3JqPEZV2k+/wOEQio/Re0SKaFVBmcR9CP+xDUuAIh
AP////////////////////66rtzmr0igO7/SXozQNkFBAgEBA0IABJJ6TBhmiWm4
Y1ACBVJVn0oyG9Ay5IzEZq8cPyrs1PERl963YQh5UrGOT0NodynfHswkz8bUpaJW
FsowR/l9wXc=
-----END PUBLIC KEY-----
        </xmp></tt></a>
        </ul>
        "
        back
    fi

elif [[ -n "$id" ]]
then
    content plain

    tar xOf "$archive" "tmp/$id"
    tar xOf "$archive" "tmp/$id.sha256" | xxd -p
    tar xOf "$archive" "tmp/$(grep "^$id," "$csv" |cut -d, -f2).pem"


elif [[ "$tx_log" = html ]]
then

    content html
    echo "
    <tt><table border=1>
    <thead>
    <tr>
    <td>ID</td>
    <td>FROM</td>
    <td>TO</td>
    <td>WHAT</td>
    <td>QUANTITY</td>
    </tr>
    </thead>
    <tbody>

    "

    (
    IFS=,
    while read id from to what quantity
    do
        echo "<tr><a name=$id></a>
        <td><a href=$(
        if [[ "$id" =~ ^bitcoin-forum: ]]
        then echo "http://www.bitcoin.org/smf/index.php?topic=${id#*:}"
        else echo "$0?id=$id"
        fi)>$id</a>
        <td>$from</td>
        <td>$to</td>
        <td>$what</td>
        <td>$quantity</td>

        </tr>"
    done < $csv
    )

    echo "
    </tbody>
    </table>
    </tt>
    "

    back

elif [[ "$tx_log" = csv ]]
then
    content "csv\nContent-disposition: attachment; filename=$csv"
    cat "$csv"

else
    content plain

    echo "unknown query string : $QUERY_STRING"
    echo
fi
