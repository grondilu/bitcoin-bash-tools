This is a set of bash functions to manipulate bitcoin addresses, but mostly to generate keys for cold storage.

## SYNOPSIS

    $ git clone https://github.com/grondilu/bitcoin-bash-tools.git
    $ cd bitcoin-bash-tools/
    $ . bitcoin.sh

    $ secp256k1 1                  # generator point G
    0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
    $ secp256k1 2                  # G + G = 2*G
    02C6047F9441ED7D6D3045406E95C07CD85C778E4B8CEF3CA7ABAC09B95C709EE5
    $ secp256k1 3                  # 3*G
    02F9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9
    $ { !-2 ; !-3 ; } |secp256k1   # with no parameter, reads points to sum on stdin
    02F9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9

    $ newBitcoinKey                # single, random bitcoin key, showing base58 addresses
    {
      "compressed": {
        "WIF": "L4xGHV92UrCpTEXAMPLEKEYDONOTUSEGdE1bub628S4BaPpJ3VDQ",
        "addresses": {
          "p2pkh": "1EeT1YP4KHEXAMPLEKEYDONOTUSE5zETzS",
          "p2sh": "384AV37keiAVDONOTUSEhRbLYwL5TxK6aH",
          "bech32": "bc1qjkhte0dEXAMPLEKEYDONOTUSEt2fypfehtftwf"
        }
      },
      "uncompressed": {
        "WIF": "5KZurW2pThbrGRyrKpSMHEXAMPLEKEYDONOTUSERGjP23APujMM",
        "addresses": {
          "p2pkh": "1K1Z2wZShjv968EXAMPLEKEYDONOTUSEej",
          "p2sh": "41EXAMPLEKEYDONOTUSE8pvfHkweX6P8cbZk"
        }
      }
    }
    $ newBitcoinKey 123 > k.json   # key from exponent, saving to file

    $ head -c 16 </dev/random |    # generating 16 random bytes
    > bip32 M                      # using them as seed to generate a master key
    > tee masterkey.priv |         # saving this key in a file before processing it
    > bip32 /n                     # creating the corresponding public extended key
    xpub661MyMwAqRbcGXJ4qGqEXAMPLEKEYDONOTUSEdq5432TRCVHJ7ArzUvvChdPwkG23xTGkThjp5bngR6xNyUEXAMPLEKEYDONOTUSEk6PdXS

    $ prove -e bash t/*.t.sh    # to run TAP tests

## REQUIREMENTS

- [bash](https://www.gnu.org/software/bash/) version 4 or above;
- [jq](https://stedolan.github.io/jq/), a command-line JSON processor;
- [dc](https://en.wikipedia.org/wiki/Dc_\(computer_program\)), the Unix desktop calculator;
- xxd, an [hex dump](https://en.wikipedia.org/wiki/Hex_dump) utility;
- openssl, the [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL) command line tool.

## TODO

- [BIP 0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) (WIP)
- [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039)
- [BIP 0032](https://en.bitcoin.it/wiki/BIP_0032) (WIP)
- use an environment variable for generating addresses on the test network. (WIP)
- [BIP 0350](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki)
- [TAP](http://testanything.org/testing-with-tap/) support.

## LICENSE

Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


