hiera-yamlgpg
=============

Decrypt Hiera YAML values encrypted with GPG

License
-------

Apache License, Version 2.0

Testing
-------

Test the code with:

  cd test
  puppet apply --modulepath=../.. --hiera_config hiera.yaml manifests/site.pp


Requires
--------

rubygem: gpgme

Contact
-------

onlynone@gmail.com

Support
-------

Please log tickets and issues at our [Projects site](https://github.com/onlynone/hiera-yamlgpg)
