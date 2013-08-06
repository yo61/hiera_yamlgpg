Introduction
============

Decrypt Hiera YAML values encrypted with GPG.

Background
==========

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

This means a contributor doesn't need your private key to add a new encrypted
parameter to a yaml file. The **yaml file itself is unencrypted**, only the
**values are encrypted**. A contributor only needs a public key to add a new
encrypted value. It also means one can have lists of encrypted values, lists of
hashes of encrypted values, lists of hashes with both encrypted and unencrypted
values, and any number of levels of such.

Installation
============

The package is distributed as a puppet module on puppet forge, if you already
have puppet installed, the module can be installed with:

    puppet module install compete/hiera_yamlgpg

The only requirement is that gpgme is installed:

    gem install gpgme

Use
===

#### TLDR:
(You already have public/private gpg keys set up, you know what you're doing,
you just want to use it.)

Add `yamlgpg` to your hiera `:backends`. Specify a `:key_dir` under the
`:yamlgpg` section that points to a GnuPG directory (defaults to `~/.gnupg`).
This backend will process files ending in `.yaml`. Use ascii armor encrypted
text (encrypted with the pubkey portion of a secret key available under
`:key_dir`) in the values of any yaml entry and they will be decrypted on the
fly by hiera.

#### Details:
On your puppet master or one of your puppet nodes, create a public and private
key with:

    gpg --gen-key --homedir /etc/puppet/keys

or, if using puppet enterprise

    gpg --gen-key --homedir /etc/puppetlabs/puppet/keys

Use a name for the key that's something like your puppet master's `fqdn`. Don't
supply a password, gpg might complain about this a lot, but just keep hitting
enter when asked to supply a password. Hiera won't be able to decrypt your
values if you use a password here. Export the newly created pubkey with:

    gpg --export KEY-NAME --homedir /etc/puppet/keys \
      > exported-pubring.gpg

Copy `exported-pubring.gpg` to your loal dev machine and import it into your
personal keyring with:

    gpg --import exported-pubring.gpg

The private key (`secring.pub`) should only reside on your puppet masters, or
if need be, distributed to your puppet servers if not running in master/agent
mode.

Then create a yaml file `hieradata/secrets.yaml` from an existing unencrypted
yaml file, such as `hieradata/unencrypted_secrets.yaml` as:

    cat hieradata/unencrypted_secrets.yaml \
      | ./scripts/encrypt_yaml.rb -r KEY-NAME \
      > hieradata/secrets.yaml

The above command will go through all the keys in the supplied yaml file and
write out a new yaml file with only encrypted values.

You can also encrypt individual text by running something like the following:

    echo -n 'secretdbpassword' \
      | gpg --armor --encrypt -r KEY-NAME \

And then pasting the output of the above into a yaml file so it looks like:

    dbpassword: |
      [PASTE THE OUTPUT OF gpg --armor --encrypt HERE]
      [MAKE SURE TO INDENT EACH LINE THE SAME AMOUNT]
    
    notsecretthing: blah

Make a `hiera.yaml` as:

    :hierarchy:
      - secrets
    
    :backends:
      - yamlgpg
    
    :yamlgpg:
      :datadir: hieradata
      :key_dir: /etc/puppet/keys # optional, defaults to ~/.gnupg

Then if you run `hiera -c hiera.yaml dbpassword` on a machine that has the
secret key you should get `secretdbpassword`. You'll need to be root to read
the keydir, and hiera_yamlgpg will need to be in your ruby library search path,
so the command might end up looking like this:

    sudo bash -c 'RUBYLIB=/etc/puppet/modules/hiera_yamlgpg/lib hiera -c hiera.yaml dbpassword'

When you use hiera as part of puppet, that path should already be on the load
path, and the process will be running as root.

License
=======
Apache License, Version 2.0

Contact
=======
swillis@compete.com

Support
=======
Please log tickets and issues at our [Projects site](https://github.com/compete/hiera_yamlgpg)
