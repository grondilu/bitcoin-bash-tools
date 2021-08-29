This is a set of bash functions to manipulate bitcoin addresses, but mostly to generate keys for cold storage.

## SYNOPSIS

    $ git clone https://github.com/grondilu/bitcoin-bash-tools.git
    $ cd bitcoin-bash-tools/
    $ . bitcoin.sh

    $ let -i a=RANDOM b=RANDOM
    $ secp256k1 $a
    $ secp256k1 $b
    $ for i in $a $b; do secp256k1 $i; done | secp256k1
    $ secp256k1 $((a+b))

    $ newBitcoinKey |tee mykey.json

    $ bip32 m < entropy
    $ bip32 m/n < entropy
    $ bip32 m/0h/5/7h < entropy

    $ prove -e bash t/*.t.sh

## REQUIREMENTS

- [bash](https://www.gnu.org/software/bash/) version 4 or above;
- [dc](https://en.wikipedia.org/wiki/Dc_\(computer_program\)), the Unix desktop calculator;
- xxd, an [hex dump](https://en.wikipedia.org/wiki/Hex_dump) utility;
- openssl, the [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL) command line tool.

## TODO

- [ ] [BIP 0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki)
- [ ] [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039)
- [ ] [BIP 0032](https://en.bitcoin.it/wiki/BIP_0032)
- [x] use an environment variable for generating addresses on the test network.
- [ ] [BIP 0350](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki)
- [x] [TAP](http://testanything.org/testing-with-tap/) support.

## LICENSE

Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


