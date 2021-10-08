# Bitcoin bash tools

[Bitcoin](http://bitcoin.org)-related functions in [Bash](https://www.gnu.org/software/bash/).

## Synopsis

    $ git clone https://github.com/grondilu/bitcoin-bash-tools.git
    $ cd bitcoin-bash-tools/
    $ . bitcoin.sh

    $ newBitcoinKey

    $ openssl rand 64 |tee seed |xkey -s m

    $ xkey -s /N < seed
    $ ykey -s /N < seed
    $ zkey -s /N < seed
    
    $ bitcoinAddress "$(xkey -s /44h/0h/0h/0/0/N < seed |base58 -c)"
    $ bitcoinAddress "$(ykey -s /49h/0h/0h/0/0/N < seed |base58 -c)"
    $ bitcoinAddress "$(zkey -s /84h/0h/0h/0/0/N < seed |base58 -c)"
    
    $ m="$(xkey -s < seed |base58 -c)"
    $ M="$(xkey -s /N < seed |base58 -c)"

    $ mnemonic=($(create-mnemonic 128))
    $ echo "${mnemonic[@]}"

    $ mnemonic-to-seed "${mnemonic[@]}" > seed

    $ prove t/*.t.sh

## Description

This repository contains bitcoin-related bash functions and programs, allowing
bitcoin private keys generation and processing from and to various formats.

### Base-58 encoding

`base58` is a simple [filter](https://en.wikipedia.org/wiki/Filter_\(software\)) implementing [Satoshi Nakamoto's binary-to-text encoding](https://en.bitcoin.it/wiki/Base58Check_encoding).
Its interface is inspired from [coreutils' base64](https://www.gnu.org/software/coreutils/base64).

    $ openssl rand 20 |base58
    2xkZS9xy8ViTSrJejTjgd2RpkZRn

With the `-c` option, the checksum is added.

    $ echo foo |base58 -c
    J8kY46kF5y6

Decoding is done with the `-d` option.

    $ base58 -d <<<J8kY46kF5y6
    foo
    M-MDjM-^E

As seen above, when writing to a terminal, `base58` will escape non-printable characters.

Input can be coming from a file when giving the filename
(or say a [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html))
as positional parameter :

    $ base58 <(echo foo)
    3csAed

A large file will take a very long time to process though, as this encoding is absolutely not
optimized to deal with large data.

### Vanilla keys

The most basic function is `newBitcoinKey` wich takes a [secp256k1](https://en.bitcoin.it/wiki/Secp256k1)
exponent as argument and displays the following corresponding strings :
 - the private key in [Wallet Import Format](https://en.bitcoin.it/wiki/Wallet_import_format);
 - the [P2PKH invoice address](https://en.bitcoin.it/wiki/Invoice_address);
 - the private key in the PEM format used by [openssl ec](https://www.openssl.org/docs/man1.0.2/man1/ec.html);

Example for the generator point (so exponent is 1) :

    $ newBitcoinKey 1
    KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn
    1BgGZ9tcN4rmREDACTEDprQz87SZ26SAMH
    read EC key
    EC Key valid.
    writing EC key
    -----BEGIN EC PRIVATE KEY-----
    MFQCAQEEIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABoAcGBSuBBAAK
    oSQDIgACeb5mfvncu6xVoGKVzocLBwKb/NstzijZWfKBWxb4F5g=
    -----END EC PRIVATE KEY-----

The three lines about 'EC key' are stderr output from `openssl ec ... -check`.
They can serve a verification step for the calculation of the public point.

With the `-u` option, the uncompressed version is returned.

With the `-t` option, the [testnet](https://en.bitcoin.it/wiki/Testnet)
version is returned.

### Extended keys

Generation and derivation of *eXtended keys*, as described in
[BIP-0032](https://en.bitcoin.it/wiki/BIP_0032) and its successors BIP-0044,
BIP-0049 and BIP-0084, are supported by three filters : `xkey`, `ykey` and
`zkey`.

To discourage the handling of keys in plain text, these functions mainly
read and print keys in *binary*.  The base58check version is only printed
when writing to a terminal.

Unless the option `-s` or `-t` is used, these functions read 78 bytes
from stdin and interpret these as a serialized extended key.   Then the
extended key derived according to a derivation path provided as a positional
parameter is computed and printed on stdout.

To feed a base58check-encoded key as input, it must first be decoded with `base58`.

    $ myxprvkey=xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
    $ base58 -d <<<"$myxprvkey" |xkey /0
    xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt

To capture the base58check-encoded result, encoding must be performed explicitely with `base58 -c`.

    $ myXkey="$(base58 -d <<<"$myxprvkey"| xkey /0 |base58 -c)"

When the `-s` option is used, stdin is used as a binary seed instead
of an extended key.  This option is thus required to generate a master key :

    $ openssl rand 64 |tee myseed |xkey -s m
    xprv9s21ZrQHREDACTEDtahEqxcVoeTTAS5dMAqREDACTEDDZd7Av8eHm6cWFRLz5P5C6YporfPgTxC6rREDACTEDn5kJBuQY1v4ZVejoHFQxUg

Any key in the key tree can be generated from a seed, though:

    $ cat myseed |xkey -s m/0h/0/0

When the `-t` option is used, stdin is used as a binary seed and the generated
key will be a testnet key.

    $ cat myseed |xkey -t m
    tprv8ZgxMBicQKsPen8dPzk2REDACTEDiRWqeNcdvrrxLsJ7UZCB3wH5tQsUbCBEPDREDACTEDfTh3skpif3GFENREDACTEDgemFAhG914qE5EC

`N` is the derivation operator used to get the so-called *neutered* key, a.k.a the public extended key.

    $ base58 -d <<<"$myxprvkey" |xkey /N
    xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB

`ykey` and `zkey` differ from `xkey` mostly by their serialization format, as described in bip-0049 and bip-0084.

    $ openssl rand 64 |tee myseed
    $ ykey -s m < myseed
    yprvABrGsX5C9jantX14t9AjGYHoPw5LV3wdRD9JH3UxsEkMsxv3BcdzSFnqNidrmQ82nnLCmu3w6PWMZjPTmLKSAdBFBnXhqoE3VgBQLN6xJzg
    $ zkey -s m < myseed
    zprvAWgYBBk7JR8GjieqUJjUQTqxVwy22Z7ZMPTUXJf2tsHG5Wa83ez3TQFqWWNCTVfyEc3tk7PxY2KTytxCMvW4p7obDWvymgbk2AmoQq1qL8Q

You can feed any file to these functions, and such file doesn't have to be 64 bytes long.
It should, however, contain at least that much entropy.

If the derivation path begins with `m` or `M`, and unless the option `-s` or
`-t` is used, additional checks are performed to ensure that the input is a
master private key or a master public key respectively.

When reading a binary seed, under the hood the seed feeds the following openssl command :

```bash
openssl dgst -sha512 -hmac "Bitcoin seed" -binary
```

The output of this command is then split in two to produce a *chain code* and a private exponent,
as described in bip-0032.

### Mnemonic

A seed can be produced from a *mnemonic*, a.k.a a *secret phrase*, as described
in [BIP-0039](https://en.bitcoin.it/wiki/BIP_0039).

To create a mnemonic, a function `create-mnemonic` takes as argument an amount of entropy in bits
either 128, 160, 192, 224 or 256.  Default is 160.

    $ create-mnemonic 128
    invest hedgehog slogan unfold liar thunder cream leaf kiss combine minor document

The function will attempt to read the [locale](https://man7.org/linux/man-pages/man1/locale.1.html)
settings to figure out which language to use.  If it fails, or if the locale language is not
supported, it will use English.

Apart from English, currently supported languages are simplified Chinese,
traditional Chinese, Japanese, Spanish and French.

To override locale language settings, set the `LANG` environment variable :

    $ LANG=zh_TW create-mnemonic
    凍 濾 槍 斷 覆 捉 斷 山 未 飛 沿 始 瓦 曰 撐

Alternatively, the function can take as argument some noise in hexadecimal (the
corresponding number of bits must be a multiple of 32).

    $ create-mnemonic "$(openssl rand -hex 20)"
    poem season process confirm meadow hidden will direct seed void height shadow live visual sauce

To create a seed from a mnemonic, there is a function `mnemonic-to-seed`.

    $ mnemonic=($(create-mnemonic))
    $ mnemonic-to-seed "${mnemonic[@]}"

This function expects several words as arguments, not a long string of space-separated words, so mind
the parameter expansion (`@` or `*` in arrays for instance).

`mnemonic-to-seed` output is in binary, but when writing to a terminal, it will escape non-printable charaters.
Otherwise, output is pure binary so it can be fed to a bip-0032-style function directly :

    $ mnemonic-to-seed "${mnemonic[@]}" |xkey -s /N

With the '-p' option, `mnemonic-to-seed` will prompt a passphrase.  With the `-P` option, it
will prompt it twice and will not echo the input.

The passphrase can also be given with the `BIP39_PASSPHRASE` environment variable :

    $ BIP39_PASSPHRASE=sesame mnemonic-to-seed "${mnemonic[@]}" |xkey -s /N

`mnemonic-to-seed` is a bit slow as it uses bash code to compute
[PBKDF2](https://fr.wikipedia.org/wiki/PBKDF2).  For faster execution, set
the environment variable `PBKDF2_METHOD` to "python".

    $ PBKDF2_METHOD=python mnemonic-to-seed "${mnemonic[@]}" |xkey -s /N

### Address generation

A function called `bitcoinAddress` takes a bitcoin key, either vanilla or
extended, and displays the corresponding bitcoin address. 

    $ bitcoinAddress KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn
    1BgGZ9tcN4rmREDACTEDprQz87SZ26SAMH

Right now, for extended keys, only neutered keys are processed.  So if you want
the bitcoin address of an extended private key, you must neuter it first.

    $ openssl rand 64 > seed
    $ bitcoinAddress "$(xkey -s /N < seed |base58 -c)"
    18kuHbLe1BheREDACTEDgzHtnKh1Fm3LCQ

*xpub*, *ypub* and *zpub* keys produce addresses of different formats, as
specified in their respective BIPs :

    $ bitcoinAddress "$(ykey -s /N < seed |base58 -c)"
    3JASVbGLpb4W9oREDACTEDB6dSWRGQ9gJm
    $ bitcoinAddress "$(zkey -s /N < seed |base58 -c)"
    bc1q4r9k3p9t8cwhedREDACTED5v775f55at9jcqqe


## Requirements

- [bash](https://www.gnu.org/software/bash/) version 4 or above;
- [dc](https://en.wikipedia.org/wiki/Dc_\(computer_program\)), the Unix desktop calculator;
- xxd, an [hex dump](https://en.wikipedia.org/wiki/Hex_dump) utility;
- openssl, the [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL) command line tool.

## TODO

- [x] [BIP 0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki)
- [x] [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039)
- [x] [BIP 0032](https://en.bitcoin.it/wiki/BIP_0032)
- [x] ~~use an environment variable for generating addresses on the test network.~~
- [ ] [BIP 0350](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki)
- [x] [TAP](http://testanything.org/) support
- [ ] offline transactions
- [ ] copy the [Bitcoin eXplorer](https://github.com/libbitcoin/libbitcoin-explorer.git) interface as much as possible

## Related projects

- [bx](https://github.com/libbitcoin/libbitcoin-explorer), a much more complete command-line utility written in C++.

## Feedback

To discuss this project without necessarily opening an issue, feel free to use the
[discussions](https://github.com/grondilu/bitcoin-bash-tools/discussions) tab.

## License

Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


