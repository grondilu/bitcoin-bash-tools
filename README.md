Bitcoin bash tools
==================

[Bitcoin](http://bitcoin.org)-related functions in [Bash](https://www.gnu.org/software/bash/).

## Table of contents
* [Synopsis](#synopsis)
* [Description](#description)
  * [Base-58](#base58)
  * [bech32](#bech32)
  * [Wallet Import Format](#wif)
  * [Extended keys](#extended)
  * [Mnemonics](#mnemonics)
    * [BIP-39](#bip39)
    * [Memory Techniques](#memtechniques)
  * [Addresses](#addresses)
  * [BIP-85](#bip85)
* [Requirements](#requirements)
* [TODO](#todo)
* [Feedback](#feedback)
* [Related projects](#related)
* [License](#license)


<a name="synopsis"/>

## Synopsis

```console
$ git clone https://github.com/grondilu/bitcoin-bash-tools.git
$ . bitcoin-bash-tools/bitcoin.sh

$ openssl rand 32 |wif

$ mnemonic=($(create-mnemonic 128))
$ echo "${mnemonic[@]}"

$ mnemonic-to-seed "${mnemonic[@]}" > seed

$ xkey -s /N < seed
$ ykey -s /N < seed
$ zkey -s /N < seed

$ bitcoinAddress "$(xkey -s /44h/0h/0h/0/0/N < seed |base58 -c)"
$ bitcoinAddress "$(ykey -s /49h/0h/0h/0/0/N < seed |base58 -c)"
$ bitcoinAddress "$(zkey -s /84h/0h/0h/0/0/N < seed |base58 -c)"

$ bip85 wif
$ bip85 mnemo
$ bip85 xprv

$ (cd bitcoin-bash-tools; prove;)
```

<a name=description />

## Description

This repository contains bitcoin-related bash functions, allowing bitcoin
private keys generation and processing from and to various formats.

To discourage the handling of keys in plain text, most of these functions
mainly read and print keys in *binary*.  The base58check version is only read
or printed when reading from or writing to a terminal.

<a name=base58 />

### Base-58 encoding

`base58` is a simple [filter](https://en.wikipedia.org/wiki/Filter_\(software\))
implementing [Satoshi Nakamoto's binary-to-text encoding](https://en.bitcoin.it/wiki/Base58Check_encoding).
Its interface is inspired from [coreutils' base64](https://www.gnu.org/software/coreutils/base64).

    $ openssl rand 20 |base58
    2xkZS9xy8ViTSrJejTjgd2RpkZRn

With the `-c` option, the checksum is added.

    $ echo foo |base58 -c
    J8kY46kF5y6

With the `-v` option, the checksum is verified.

    $ echo foo |base58   |base58 -v || echo wrong checksum
    wrong checksum
    $ echo foo |base58 -c|base58 -v && echo good checksum
    good checksum

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

<a name=bech32 />

### Bech32

[Bech32](https://en.bitcoin.it/wiki/Bech32) is a string format used to encode
[segwit](https://en.bitcoin.it/wiki/Segregated_Witness) addresses, but by
itself it is not a binary-to-text encoding, as it needs additional conventions
for padding.

Therefore, the `bech32` function in this library does not read binary data, but
merely creates a Bech32 string from a human readable part and a non checked data
part :

    $ bech32 this-part-is-readable-by-a-human qpzry
    this-part-is-readable-by-a-human1qpzrylhvwcq

The `-m` option creates a
[bech32m](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki)
string :

    $ bech32 -m this-part-is-readable-by-a-human qpzry
    this-part-is-readable-by-a-human1qpzry2tuzaz

The `-v` option can be used to verify the checksum :

    $ bech32 -v this-part-is-readable-by-a-human1qpzrylhvwcq && echo good checksum
    good checksum

    $ bech32 -m -v this-part-is-readable-by-a-human1qpzry2tuzaz && echo good checksum
    good checksum

<a name=wif />

### Wallet Import Format

The function `wif` reads 32 bytes from stdin,
interprets them as a [secp256k1](https://en.bitcoin.it/wiki/Secp256k1) exponent
and displays the corresponding private key in [Wallet Import
Format](https://en.bitcoin.it/wiki/Wallet_import_format).

    $ openssl rand 32 |wif
    L1zAdArjAUgbDKj8LYxs5NsFk5JB7dTKGLCNMNQXyzE4tWZBGqs9

With the `-u` option, the uncompressed version is returned.

With the `-t` option, the [testnet](https://en.bitcoin.it/wiki/Testnet)
version is returned.

With the `-d` option, the reverse operation is performed : reading a
key in WIF from stdin and printing 32 bytes to non-terminal standard output.
When writing to a terminal, the output is in a format used by
[openssl ec](https://www.openssl.org/docs/man1.0.2/man1/ec.html).


<a name=extended />

### Extended keys

Generation and derivation of *eXtended keys*, as described in
[BIP-0032](https://en.bitcoin.it/wiki/BIP_0032) and its successors BIP-0044,
BIP-0049 and BIP-0084, are supported by three filters, namely `bip32`, `bip49` and `bip84`,
along with three respective aliases `xkey`, `ykey` and `zkey`.
The aliases exist for the sole reason that they are arguably easier to type.

Unless the option `-p`, `-s` or `-t` is used, these functions read 78 bytes
from stdin and interpret these as a serialized extended key.   Then the
extended key derived according to a derivation path provided as a positional
parameter is computed and printed on stdout.

A base58check-encoded key can be passed as input if it is pasted
in the terminal, but to pass it through a pipe, it must first be decoded with
`base58 -d`:

    $ myxprvkey=xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
    $ base58 -d <<<"$myxprvkey" |xkey /0
    xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt

To capture the base58check-encoded result, encoding must be performed explicitely with `base58 -c`.

    $ myXkey="$(base58 -d <<<"$myxprvkey"| xkey /0 |base58 -c)"

When the `-s` option is used, stdin is used as a binary seed instead
of an extended key.  This option is thus required to generate a master key :

    $ openssl rand 64 |tee myseed |xkey -s
    xprv9s21ZrQHREDACTEDtahEqxcVoeTTAS5dMAqREDACTEDDZd7Av8eHm6cWFRLz5P5C6YporfPgTxC6rREDACTEDn5kJBuQY1v4ZVejoHFQxUg

Any key in the key tree can be generated from a seed, though:

    $ xkey -s m/0h/0/0 < myseed

When the `-t` option is used, stdin is used as a binary seed and the generated
key will be a testnet key.

    $ xkey -t < myseed
    tprv8ZgxMBicQKsPen8dPzk2REDACTEDiRWqeNcdvrrxLsJ7UZCB3wH5tQsUbCBEPDREDACTEDfTh3skpif3GFENREDACTEDgemFAhG914qE5EC

`N` is the derivation operator used to get the so-called *neutered* key, a.k.a the public extended key.

    $ base58 -d <<<"$myxprvkey" |xkey /N
    xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB

`ykey` and `zkey` differ from `xkey` mostly by their serialization format, as described in bip-0049 and bip-0084.

    $ openssl rand 64 > myseed
    $ ykey -s < myseed
    yprvABrGsX5C9jantX14t9AjGYHoPw5LV3wdRD9JH3UxsEkMsxv3BcdzSFnqNidrmQ82nnLCmu3w6PWMZjPTmLKSAdBFBnXhqoE3VgBQLN6xJzg
    $ zkey -s < myseed
    zprvAWgYBBk7JR8GjieqUJjUQTqxVwy22Z7ZMPTUXJf2tsHG5Wa83ez3TQFqWWNCTVfyEc3tk7PxY2KTytxCMvW4p7obDWvymgbk2AmoQq1qL8Q

You can feed any file to these functions, and such file doesn't have to be 64 bytes long.
It should, however, contain at least that much entropy.

If the derivation path begins with `m` or `M`, and unless the option `-p`, `-s` or
`-t` is used, additional checks are performed to ensure that the input is a
master private key or a master public key respectively.

When reading a binary seed, under the hood the seed feeds the following openssl command :

```bash
openssl dgst -sha512 -hmac "Bitcoin seed" -binary
```

The output of this command is then split in two to produce a *chain code* and a private exponent,
as described in bip-0032.

<a name=mnemonics />

### Mnemonics

It is possible to store the keys of a hierarchical deterministic wallet in biological
memory using mnemonics.  There are at least two ways to do so : the first one
is to follow the dedicated BIP, and the other is to use known memory techniques.

<a name=bip39 />

#### Bip-39

A seed can be produced from a *mnemonic*, a.k.a a *secret phrase*, as described
in [BIP-0039](https://en.bitcoin.it/wiki/BIP_0039).

To create a mnemonic, a function `create-mnemonic` takes as argument an amount of entropy in bits
either 128, 160, 192, 224 or 256.  Default is 160.

    $ create-mnemonic 128
    invest hedgehog slogan unfold liar thunder cream leaf kiss combine minor document

The function will attempt to read the [locale](https://man7.org/linux/man-pages/man1/locale.1.html)
settings to figure out which language to use.  If it fails, or if the local language is not
supported, it will use English.

<!-- NYI
BIP-0039 discourages the use of non-English words, so by default the library
will use English word.  To override this and use the locale settings, set 
the `BIP39_USE_LANG` environment variable to `yes`.  The library will
then use the `LANG` environment variable if possible.

This must be done before loading the library.

    $ BIP39_USE_LANG=yes LANG=zh_CN
    $ . bitcoin.sh
    $ create-mnemonic
    凍濾槍斷覆捉斷山未飛沿始瓦曰撐

As you can see, Chinese output does not use spaces.
-->

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

With the `-p` option, `mnemonic-to-seed` will prompt a passphrase.  With the `-P` option, it
will prompt it twice and will not echo the input.

The passphrase can also be given with the `BIP39_PASSPHRASE` environment variable :

    $ BIP39_PASSPHRASE=sesame mnemonic-to-seed "${mnemonic[@]}" |xkey -s /N

<a name=memtechniques />

#### Memory Techniques

An alternative to bip-39 is to use [memory techniques](https://artofmemory.com/).

Once you've become familiar with these techniques, you can generate a seed in
several ways, you just have to make sure you remember your choice of encoding.
For instance, if you've memorized a long number in decimal, you could either
use its representation in ASCII or a byte stream generated from it with dc's
`P` command.

<a name=addresses />

### Address generation

A function called `bitcoinAddress` takes a bitcoin key, either vanilla or
extended, and displays the corresponding bitcoin address. Unlike functions
described above, `bitcoinAddress` currently takes input as positional parameters,
and not from stdin.  This might change in future versions, as it is probably
not a good idea to write bitcoin private keys in plain text on the command line.

For a vanilla private key in WIF,
the [P2PKH invoice address](https://en.bitcoin.it/wiki/Invoice_address)
is produced :

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


<a name=bip85 />

### BIP85

The `bip85` function implements [BIP-0085](https://en.bitcoin.it/wiki/BIP_0085),
a method of normalizing generation and format of entropy from a given master extended private key.

The function reads a master extended private key from standard input, as `xkey` would.  When reading from a terminal,
the function will expect the base58-checked encoding.  Otherwise it will expect the binary version.

For illustration purpose, we'll use the same key used for the test vectors in BIP-0085.

    $ root=xprv9s21ZrQH143K2LBWUUQRFXhucrQqBpKdRRxNVq2zBqsx8HVqFk2uYo8kmbaLLHRdqtQpUm98uKfu3vca1LqdGhUtyoFnCNkfmXRyPXLjbKb

The general syntax is `bip85 APP [PARAMETERS...]`, where *APP* is a word designating the desired application,
as described below.

#### Mnemonic

To create a bip-39 mnemonic, use `mnemo` as *APP*.  The optional parameters are
the number of words (default is 12) and the index (default is zero).

    $ base58 -d <<<"$root" | bip85 mnemo
    girl mad pet galaxy egg matter matrix prison refuse sense ordinary nose

#### HD-Seed WIF

To create a hd-seed, use `wif` as *APP*.  The WIF will only be printed on a terminal.

    $ base58 -d <<<"$root" | bip85 wif
    Kzyv4uF39d4Jrw2W7UryTHwZr1zQVNk4dAFyqE6BuMrMh1Za7uhp

You can specify an optional index :

    $ base58 -d <<<"$root" | bip85 wif 1
    L45nghBsnmqaGj9VyREDACTEDJNi6K4LUFP4REDACTEDLEyXUkYP

#### Extended master key

To derive an other extended master key, use `xprv` as *APP*.

    $ base58 -d <<<"$root" | bip85 xprv
    xprv9s21ZrQH143K2srSbCSg4m4kLvPMzcWydgmKEnMmoZUurYuBuYG46c6P71UGXMzmriLzCCBvKQWBUv3vPB3m1SATMhp3uEjXHJ42jFg7myX

You can specify an optional index :

    $ base58 -d <<<"$root" | bip85 xprv 1
    xprv9s21ZrQH143K38mDZkjREDACTEDWyjWiejciPyREDACTED9Vg3WCWnhkPW3rKsPT6u3MREDACTEDxjBjFES1xCzEtxTSAfQTapE7CXcbQ4b

<a name=requirements />

## Requirements

- [bash](https://www.gnu.org/software/bash/) version 4 or above;
- [GNU's Coreutils](https://www.gnu.org/software/coreutils/);
- [dc](https://en.wikipedia.org/wiki/Dc_\(computer_program\)), the Unix desktop calculator;
- openssl, the [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL) command line tool.

<a name=todo />

## TODO

* [x] [BIP 0032](https://en.bitcoin.it/wiki/BIP_0032)
* [x] [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039)
* [ ] [BIP 0085](https://github.com/bitcoin/bips/blob/master/bip-0085.mediawiki)
* [x] [BIP 0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki)
* [x] [BIP 0350](https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki)
* [x] [TAP](http://testanything.org/) support
* [ ] offline transactions
* [ ] ~~copy the [Bitcoin eXplorer](https://github.com/libbitcoin/libbitcoin-explorer.git) interface as much as possible~~
* [ ] put everything in a single file
* [x] use [Jacobian coordinates](https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates)
* [ ] use a better exponentiation method, for instance using precomputations
* [ ] always output public keys in ASCII, and private keys in binary


<a name=related />

## Related projects

- [bx](https://github.com/libbitcoin/libbitcoin-explorer), a much more complete command-line utility written in C++.
- [learnmeabitcoin.com](https://learnmeabitcoin.com/), a very nice website explaining how bitcoin works.

<a name=feedback />

## Feedback

To discuss this project without necessarily opening an issue, feel free to use the
[discussions](https://github.com/grondilu/bitcoin-bash-tools/discussions) tab.

<a name=license />

## License

Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


