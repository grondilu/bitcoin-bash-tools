# Bitcoin bash tools

This is a set of bash functions to generate bitcoin private keys and addresses.

## Synopsis

    $ git clone https://github.com/grondilu/bitcoin-bash-tools.git
    $ cd bitcoin-bash-tools/
    $ . bitcoin.sh

    $ newBitcoinKey

    $ openssl rand 64 > entropy

    $ . bip-0032.sh
    $ m="$(bip32 < entropy)"
    $ bip32 $m/N
    $ bip32 $m/0h/5/7
    
    $ . bip-0039.sh
    $ create-mnemonic 128
    drip goose mansion fashion display detail high elder expose rain outdoor poet
    $ mnemonic-to-seed drip goose mansion fashion display detail high elder expose rain outdoor poet
    3635d3c21228487465d24a486e8063dc6730b7ced192cfdaed35b382277ac798aab7f779e58a3e253d1ef1c21f0f5442d4d3f419ac766471541d1e20d39f68b0
    $ mnemonic-to-seed drip duck mansion fashion display detail high elder expose rain outdoor poet
    WARNING: wrong mnemonic checksum.
    52491c9b9e7153a23081453e37f86fe61fa1c56769258357a30954018c99637a0b9e7b9d6c41d91805ed23f3f9f5127415dd43cd3a83dc84e6db03111fe231d5

    $ . bip-0173.sh
    $ segwitAddress -p 0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798

    $ prove t/*.t.sh

## Requirements

- [bash](https://www.gnu.org/software/bash/) version 4 or above;
- [dc](https://en.wikipedia.org/wiki/Dc_\(computer_program\)), the Unix desktop calculator;
- xxd, an [hex dump](https://en.wikipedia.org/wiki/Hex_dump) utility;
- openssl, the [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL) command line tool.

## TODO

- [ ] [BIP 0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki)
- [x] [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039)
- [x] [BIP 0032](https://en.bitcoin.it/wiki/BIP_0032)
- [x] ~~use an environment variable for generating addresses on the test network.~~
- [ ] [BIP 0350](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki)
- [x] [TAP](http://testanything.org/testing-with-tap/) support
- [ ] offline transactions
- [ ] copy the [Bitcoin eXplorer](https://github.com/libbitcoin/libbitcoin-explorer.git) interface as much as possible

## Related projects

- [bx](https://github.com/libbitcoin/libbitcoin-explorer), a much more complete command-line utility written in C++.

## Feedback

To discuss this project without necessarily open an issue, feel free to use the
[discussions](https://github.com/grondilu/bitcoin-bash-tools/discussions) tab.

## License

Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


