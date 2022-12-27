# GnuPG / GPG / OpenPGP

## Installation

### macOS

```bash
brew install gnupg
```

### Linux: Debian/Ubuntu (should be already installed)
  
```bash
sudo apt install gnupg
```

### Configuration files

```bash
touch ~/.gnupg/gpg.conf
touch ~/.gnupg/gpg-agent.conf
```

Configuration files are in this repo: [.gnupg/](.gnupg/)

## Cookbook for creating new key from scratch

### Introduction. What we want to achieve

* **Primary**, **master key will be kept offline**. This key will only be used to generate and control secure sub keys
  * [C] - **Certify**
* Secure keys that are going to be used by You are:
  * [S] - **Sign**
  * [A] - **Authenticate**
  * [E] - **Encrypt**

```bash
# [C] - Certify
# [S] - Sign
# [A] - Authenticate
# [E] - Encrypt

# List public keys
felixd@192:~$ gpg -k

/Users/felixd/.gnupg/pubring.kbx
--------------------------------
pub   nistp521/0x9CC77B3A8866A558 2021-03-19 [C] # <-- [C] - Certify
      Key fingerprint = E0F9 4FE7 93B7 1D7E C147  5ECD 9CC7 7B3A 8866 A558
uid                   [ultimate] Paweł Wojciechowski <felixd@konopnickiej.com>
uid                   [ultimate] Paweł Wojciechowski <felixd@wp.pl>
sub   nistp521/0x784E7C68559BA960 2021-03-19 [S] [expires: 2023-03-19]
sub   nistp521/0x5F7748EAAA46D8A4 2021-03-19 [E] [expires: 2023-03-19]
sub   nistp521/0x07AD11F0AE1DAAF2 2021-03-19 [A] [expires: 2023-03-19]

# List secure keys
felixd@192:~$ gpg -K

/Users/felixd/.gnupg/pubring.kbx
--------------------------------
sec#  nistp521/0x9CC77B3A8866A558 2021-03-19 [C]
      Key fingerprint = E0F9 4FE7 93B7 1D7E C147  5ECD 9CC7 7B3A 8866 A558
uid                   [ultimate] Paweł Wojciechowski <felixd@konopnickiej.com>
uid                   [ultimate] Paweł Wojciechowski <felixd@wp.pl>
ssb   nistp521/0x784E7C68559BA960 2021-03-19 [S] [expires: 2023-03-19]
ssb   nistp521/0x5F7748EAAA46D8A4 2021-03-19 [E] [expires: 2023-03-19]
ssb   nistp521/0x07AD11F0AE1DAAF2 2021-03-19 [A] [expires: 2023-03-19]

```

If personally prefer **Elliptic-curve cryptography. Read more about it on Wikipedia: https://en.wikipedia.org/wiki/Elliptic-curve_cryptography

```txt
+---------------+-------------------------+-----------------+
| Symmetric Key | RSA and Diffie-Hellman  | Elliptic Curve  |
| Size (bits)   |      Key Size (bits)    | Key Size (bits) |
+---------------+-------------------------+-----------------+
|       80      |            1024         |       160       |
|      112      |            2048         |       224       |
|      128      |            3072         |       256       |
|      192      |            7680         |       384       |
|      256      |           15360         |       521       |
+---------------+-------------------------+-----------------+
             Table 1: NIST Recommended Key Sizes
```

To generate ECC keys use below command:

```bash
gpg --full-generate-key --expert
```

Then select `EEC / (5) NIST P-521`

```bash
* ECC / (5) NIST P-521
RSA / 4096 bit
```

## Files size when GPG encrypts for multiple recipients

* https://security.stackexchange.com/questions/8245/gpg-file-size-with-multiple-recipients

GPG encrypts the file once with a symmetric key, then places a header identifying the target keypair and an encrypted version of the symmetric key. The intricate details of that are defined in section 5.1 of RFC 2440. When encrypted to multiple recipients, this header is placed multiple times providing a uniquely encrypted version of the same symmetric key for each recipient.

Thus, file size growth for each recipient is small and roughly linear. Some variation may exist for key length and padding so it's not predictable different for different key sizes and algorithms, but it's small. In a quick test demonstration using no compression:

```bash
gpg --encrypt --recipient alice@example.com \
    --recipient bob@example.com doc.txt
```

```bash
11,676,179 source
11,676,785 encrypted-to-one (+606 bytes)
11,677,056 encrypted-to-two (+277 bytes)
11,677,329 encrypted-to-three (+273 bytes)
```

## OpenPGP Key Servers

Below services provide option to store and to **manage** Your public keys:

* https://keys.openpgp.org
* https://keys.mailvelope.com/manage.html

Below services provide option to upload and store keys (no chance to manage them)

* https://keyserver.ubuntu.com/
* https://pgp.mit.edu/

### Exporting public key to Key Server

```bash
gpg --export you@example.org | curl -T - https://keys.openpgp.org
```

## Import/Export keys [general]

* https://www.debuntu.org/how-to-importexport-gpg-key-pair/

```bash
felixd@192:~/ [master]$ gpg --list-keys

# Key I am interested in: 0x9CC77B3A8866A558
KEY="0x9CC77B3A8866A558"
gpg --output ${KEY}.gpg.public.asc --armor --export $KEY
gpg --output ${KEY}.gpg.private.asc --armor --export-secret-key $KEY
gpg --output ${KEY}.gpg.private_sub.asc --armor --export-secret-subkeys $KEY

felixd@remotehost:~$ gpg --import ${KEY}.gpg.public.asc
felixd@remotehost:~$ gpg --allow-secret-key-import --import ${KEY}.gpg.private_sub.asc
```

## Git/SSH and GPG

* https://docs.github.com/en/github/authenticating-to-github/signing-commits
* https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work

```bash
git config --global commit.gpgsign true
git config --global user.signingkey 0x9CC77B3A8866A558
```

### Windows

In case you receive error messages that GPG secret sign key is missing:

```log
gpg: skipped "0x9CC77B3A8866A558": No secret key
gpg: signing failed: No secret key
error: gpg failed to sign the data
fatal: failed to write commit object
```

set in Git configuration path to GPG program:

```bash
git config --global gpg.program "C:/Program Files (x86)/gnupg/bin/gpg.exe"
```

![image](https://user-images.githubusercontent.com/4963164/111005115-7ebd6900-838a-11eb-830d-35fcce4590a1.png)

## Mailvelope: OpenPGP on Web Mail (Gmail, Yahoo Mail, etc) encryption/decryption/singing

To integrated GnuPG with your Web Mail clinet use Mailvelope: https://www.mailvelope.com

* https://github.com/mailvelope/mailvelope/wiki/Mailvelope-GnuPG-integration

### gpg: public key decryption failed: Inappropriate ioctl for device

Mailvelope needs password to encode/sign mail when using GnuPG with browser.

* https://github.com/Homebrew/homebrew-core/issues/14737#issuecomment-309547412

```bash
brew install gpgme pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent
```

## Change key expiration date

```bash
KEY="0x9CC77B3A8866A558"
gpg --list-keys
gpg --edit-key $KEY
```

Now we are inside GPG. Use the `expire` command to set a new expire date:

```bash
gpg> expire
```

When prompted type `1y` or however long you want the key to last for.

Select all the subkeys (the primary key, which we just set the expires date for, is key 0):

```bash
gpg> key 1
gpg> key 2
gpg> key 3
gpg> expire

gpg> trust
gpg> save

KEY="0x9CC77B3A8866A558"
gpg --output ${KEY}.gpg.public.asc --armor --export $KEY
gpg --output ${KEY}.gpg.private.asc --armor --export-secret-key $KEY
gpg --output ${KEY}.gpg.private_sub.asc --armor --export-secret-subkeys $KEY
```

Move the keys on to something like a USB drive and store it safely in another location.

Publish the public key:

```bash
KEY="0x9CC77B3A8866A558"
gpg --keyserver keyserver.ubuntu.com --send-keys $KEY
gpg --keyserver pgp.mit.edu --send-keys $KEY
gpg --keyserver keys.openpgp.org --send-keys $KEY
```

## Best Practices

* https://riseup.net/pl/security/message-security/openpgp/gpg-best-practices

## Author

* Paweł 'felixd' Wojciechowski [0x9CC77B3A8866A558](https://keys.openpgp.org/vks/v1/by-fingerprint/E0F94FE793B71D7EC1475ECD9CC77B3A8866A558)
```bash
E0F94FE793B71D7EC1475ECD9CC77B3A8866A558

curl https://keys.openpgp.org/vks/v1/by-fingerprint/E0F94FE793B71D7EC1475ECD9CC77B3A8866A558 | gpg --import
```

## Donations & Support

If You would like to support this project:

* **BTC**: bc1qe4clvflldgqw5s9y0yn3lm99lz9yf9mn4x3zfe
