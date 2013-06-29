$password = hiera('password', 'NOVALUE')
$kindasecret = hiera('kindasecret', 'NOVALUE')
$notsosecret = hiera('notsosecret', 'NOVALUE')

notify{"password: ${password}":}
notify{"kindasecret: ${kindasecret}":}
notify{"notsosecret: ${notsosecret}":}
