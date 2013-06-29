Introduction
============

Decrypt Hiera YAML values encrypted with GPG.

Details
=======

Inspiration for this project came from
[hiera-gpg](https://github.com/crayfishx/hiera-gpg). But hiera_yamlgpg gives
you more flexibility:

 * hiera_yamlgpg decrypts just the values inside yaml files whereas hiera-gpg
   requires that the entire file is encrypted.
 * hiera_yamlgpg is a puppet module, hiera-gpg is a ruby gem.
 * hiera_yamlgpg will only decrypt values that look like they've been encrypted
   and will treat unencrypted values just as the normal yaml backend would.
 * hiera_yamlgpg will deep dive into hashes and arrays and only attempt to
   decrypt values that are strings.

This means a contributor doesn't your private key to add a new encrypted
parameter to a yaml file. The **yaml file itself is unencrypted**, only the
**values are encrypted**. A contributor only needs a public key to add a new
encrypted value. It also means one can have lists of encrypted values, lists of
hashes of encrypted values, lists of hashes with both encrypted and unencrypted
values, and any number of levels of such.

Installation
============

The package is distributed as a puppet module on puppet forge, if you already
have puppet installed, the module can be installed with:

    puppet module install onlynone/hiera_yamlgpg

The only requirement is that gpgme is installed:

    gem install gpgme

Use
===

Create a public and private key with `gpg --gen-key` then encrypt some text with:

    echo -n 'Some Text' \
      | gpg --armor --encrypt \
      > encrypted_file.gpg

Then create a yaml file `hieradata/secret.yaml` as:

    secretthing: |
      [PASTE THE CONTENTS OF encrypted_file.gpg HERE]
      [MAKE SURE TO INDENT EACH LINE THE SAME AMOUNT]
    
    notsecretthing: blah

And create a `hiera.yaml` as:

    :hierarchy:
      - secret
    
    :backends:
      - yamlgpg
    
    :yamlgpg:
      :datadir: hieradata
      :key_dir: ~/.gnupg # optional, defaults to ~/.gnupg

Then if you run `hiera -c hiera.yaml secretthing` you should get `Some Text`

License
=======
Apache License, Version 2.0

Contact
=======
onlynone@gmail.com

Support
=======
Please log tickets and issues at our [Projects site](https://github.com/onlynone/hiera_yamlgpg)
