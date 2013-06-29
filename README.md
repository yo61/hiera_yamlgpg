hiera-yamlgpg
=============

Decrypt Hiera YAML values encrypted with GPG

Testing
=======

Test the code with:

  cd test
  puppet apply --modulepath=../modules --hiera_config hiera.yaml manifests/site.pp


Requires
========

gpgme
