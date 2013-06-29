hiera_yamlgpg
=============

Decrypt Hiera YAML values encrypted with GPG. Inspiration for this project comes
from [hiera-gpg](https://github.com/crayfishx/hiera-gpg). The differences
between that project and this one are:

 * hiera_yamlgpg decrypts just the values inside yaml files whereas hiera-gpg
   requires that the entire file is encrypted.
 * hiera_yamlgpg is a puppet module, hiera-gpg is a ruby gem.

In addition:

 * hiera_yamlgpg will only decrypt values that look like they've been encrypted
   and will treat unencrypted values just as the normal yaml backend.
 * hiera_yamlgpg will deep dive into hashes and arrays and only attempt to
   decrypt strings

This means that with hiera_yamlgpg, a contributor doesn't need the pupmaster's
private key to add a new encrypted parameter to a yaml file. The file itself is
unencrypted, only the values are encrypted. A contributor only needs the public
key to encrypt the new value to add it to the yaml file. It also means one can
have lists of encrypted values, lists of hashes of encrypted values, lists of
hashes with mixed encrypted and unencrypted values, and any number of levels of
such.

License
-------

Apache License, Version 2.0

Testing
-------

Test the code with:

    $ cd test
    $ puppet apply --modulepath=../.. --hiera_config hiera.yaml manifests/site.pp


Requires
--------

rubygem: gpgme

Contact
-------

onlynone@gmail.com

Support
-------

Please log tickets and issues at our [Projects site](https://github.com/onlynone/hiera_yamlgpg)
