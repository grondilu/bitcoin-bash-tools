This is a set of bash tools to manipulate bitcoin addresses, but mostly to generate keys for cold storage.

## SYNOPSIS

    $ git clone https://github.com/grondilu/bitcoin-bash-tools.git
    $ cd ./bitcoin-bash-tools/
    $ . bitcoin.sh
    $ newBitcoinKey

## REQUIREMENTS

- [bash](https://www.gnu.org/software/bash/) version 4 or above
- [jq](https://stedolan.github.io/jq/), a command-line JSON processor
- xxd, dc, openssl and possibly others.

## TODO

- generate bech32 addresses (currently implemented, but not tested nearly enough).
- create a test suite (in progress)
- [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039)
- [BIP 0032](https://en.bitcoin.it/wiki/BIP_0032)

## LICENSE

Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


