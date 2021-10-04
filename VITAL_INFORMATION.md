# Example

Here is an example run of this script:

```
petjal@petjal-ThinkPad-E520:~/dev/github/petjal/bitcoin-bash-tools$ bash MyFirstBitcoinSeedWordsAndAddress.bash
You must understand and following the guidance provided at https://github.com/petjal/bitcoin-bash-tools/blob/pjdev/VITAL_INFORMATION.md

generating as much entropy as reasonably practical, will take a few seconds...
....................
Linux entropy_avail: 3696 : greater than 200 is good

HERE IS YOUR BITCOIN SECRET SEED PHRASE: iron cinnamon obtain talk power badge library group since diagram utility west

This next step will take up to two minutes or more on a low-powered computer such as a raspberry pi...
PBKFD2: bloc 1/1, iteration 2048/2048

HERE IS YOUR PUBLIC BITCOIN ADDRESS: bc1qy6j4m00ndu9h5dszyk3p7fand6xw37d9nezyw0
```

# This script generates two very important strings of characters.
- The first is your `BITCOIN SECRET SEED PHRASE`.
- The second is your `PUBLIC BITCOIN ADDRESS`.


# Entropy 
Entropy is a vital part of bitcoin cryptography.  It must be very, very good.

# Regarding your `BITCOIN SECRET SEED PHRASE`:
- Order matters. 
    - The order of the words in your `BITCOIN SECRET SEED PHRASE` matters.
- Do not lose them. 
    - Without this sequence of 12 words, you have lost all your bitcoin. 
    - Keep them where you keep your most valuable documents.
        - a safe or safe deposit box, a password manager (consider bitwarden, keepass).
- Do not share them. 
    - With them, anyone can steal your bitcoin.
- Bequeath them.  
    - Add them to your succession plan, your last will and testament, to pass them, and thus your bitcoin, on to your heirs.
- Memorize them.  
    - Best is to memorize them; add a weekly reminder to your calendar.
    - A few good memorization techniques:
        - https://en.wikipedia.org/wiki/Mnemonic_major_system
        - https://en.wikipedia.org/wiki/Mnemonic_peg_system
        - https://en.wikipedia.org/wiki/Method_of_loci
        - https://en.wikipedia.org/wiki/Active_recall
        - https://en.wikipedia.org/wiki/Spaced_repetition

# Buy bitcoin.
Sign up on a bitcoin exchange to buy bitcoin every week or so.
- Dollar-cost averaging, "stacking sats". 
- Consider swanbitcoin.com, pro.coinbase.com ("pro" is cheaper than regular coinbase.com).

# Possess your bitcoin.
Regarding your `PUBLIC BITCOIN ADDRESS`:
- "Not your keys, not your coin." 
- You really don't own your bitcoin until they have been sent by the exchange to your `PUBLIC BITCOIN ADDRESS`, which is protected by your private seed phrase (and thus your private key).
- Arrange for the bitcoin exchange to automatically withdraw or send your bitcoin to your `PUBLIC BITCOIN ADDRESS`, as much as possible, as often as possible, as soon as possible. 

# Study bitcoin. 
- Improve your bitcoin security over time.
- It is changing the world.  
- Introduce someone else to bitcoin.
- Ask if you need help. 
