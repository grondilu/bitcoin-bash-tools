# Bitcoin bash tools

[Bitcoin](http://bitcoin.org)-related functions in [Bash](https://www.gnu.org/software/bash/).

## Synopsis

    $ git clone https://github.com/grondilu/bitcoin-bash-tools.git
    $ cd bitcoin-bash-tools/
    $ . bitcoin.sh

    $ newBitcoinKey

    $ openssl rand 64 |tee seed |xkey

    $ xkey /N < seed
    $ ykey /N < seed
    $ zkey /N < seed
    
    $ bitcoinAddress "$(xkey /44h/0h/0h/0/0/N < seed)"
    $ bitcoinAddress "$(ykey /49h/0h/0h/0/0/N < seed)"
    $ bitcoinAddress "$(zkey /84h/0h/0h/0/0/N < seed)"
    
    $ m="$(xkey < seed)"
    $ M="$(xkey $m/N)"

    $ mnemonic=($(create-mnemonic 128))
    $ echo "${mnemonic[@]}"

    $ mnemonic-to-seed -b "${mnemonic[@]}" > seed

    $ prove t/*.t.sh

## Description

This repository contains bitcoin-related bash functions and programs, allowing
bitcoin private keys generation in various formats.

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

### Extended keys

Generation and derivation of *eXtended keys*, as described in
[BIP-0032](https://en.bitcoin.it/wiki/BIP_0032) and its successors BIP-0044,
BIP-0049 and BIP-0084, are supported by three functions : `xkey`, `ykey` and
`zkey`.  These functions read either a binary seed from standard input, or use
an argument given as a serialized key with an optional derivation path :

    $ openssl rand 64 |xkey
    xprv9s21ZrQH143K2Ygi8BSgCox77K5jyh3eVhRj6CMWp2D8bgzi9iBQ2GDgttvbtm7eJf2gox4Aty7LkoSwXHfUrkkHgVutoKx8VPhRsy9gkwv

    $ m="$(openssl rand 64 |xkey)"; xkey $m/0h/N

`N` is the derivation operator used to get the so-called *neutered* key, a.k.a the public extended key.

`ykey` and `zkey` differ from `xkey` mostly by their serialization format, as described in bip-0049 and bip-0084.

    $ openssl rand 64 |ykey
    yprvABrGsX5C9jantX14t9AjGYHoPw5LV3wdRD9JH3UxsEkMsxv3BcdzSFnqNidrmQ82nnLCmu3w6PWMZjPTmLKSAdBFBnXhqoE3VgBQLN6xJzg
    $ openssl rand 64 |zkey
    zprvAWgYBBk7JR8GjieqUJjUQTqxVwy22Z7ZMPTUXJf2tsHG5Wa83ez3TQFqWWNCTVfyEc3tk7PxY2KTytxCMvW4p7obDWvymgbk2AmoQq1qL8Q

You can feed any file to these functions, and such file doesn't have to be 64 bytes long.
It should, however, contain at least that much entropy.

If the argument consists only of a derivation path, then the functions reads the seed from stdin as for master key generation, and then applies the derivation path.

    $ openssl rand 64 |tee seed |xkey /0h/0/0/N

In that case one should make sure the seed is being saved somewhere, since the
master key itself was not saved anywhere.  Thus in the example above the seed
was saved in a file, using the `tee` command.

Under the hood, the seed feeds the following openssl command :

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

Alternatively, the function can take as argument some noise in hexadecimal (the
corresponding number of bits must be a multiple of 32).

    $ create-mnemonic "$(openssl rand -hex 20)"
    poem season process confirm meadow hidden will direct seed void height shadow live visual sauce

To create a seed from a mnemonic, there is a function `mnemonic-to-seed`.

    $ mnemonic=($(create-mnemonic))
    $ mnemonic-to-seed "${mnemonic[@]}"

This function expects several words as arguments, not a long string of space-separated words, so mind
the parameter expansion (`@` or `*` in arrays for instance).

By default, the ouput is in hexadecimal.  For a binary output that can be fed directly to say `xkey`,
use the `-b` option.

    $ mnemonic-to-seed -b "${mnemonic[@]}" |xkey /N

This function is a bit slow as it uses bash code to compute
[PBKDF2](https://fr.wikipedia.org/wiki/PBKDF2).  For a faster execution, set
the environment variable `PBKDF2_METHOD` to "python".

    $ PBKDF2_METHOD=python mnemonic-to-seed -b "${mnemonic[@]}" |xkey /N

### Address generation

A function called `bitcoinAddress` takes a bitcoin key, either vanilla or
extended, and displays the corresponding bitcoin address. 

    $ bitcoinAddress KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn
    1BgGZ9tcN4rmREDACTEDprQz87SZ26SAMH

Right now, for extended keys, only neutered keys are processed.  So if you want
the bitcoin address of an extended private key, you must neuter it first.

    $ openssl rand 64 > seed
    $ bitcoinAddress "$(xkey /N < seed)"
    18kuHbLe1BheREDACTEDgzHtnKh1Fm3LCQ

*xpub*, *ypub* and *zpub* keys produce addresses of different formats, as
specified in their respective BIPs :

    $ bitcoinAddress "$(ykey /N < seed)"
    3JASVbGLpb4W9oREDACTEDB6dSWRGQ9gJm
    $ bitcoinAddress "$(zkey /N < seed)"
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


