$password = hiera('password')
$notsosecret = hiera('notsosecret')

notify{"password: ${password}":}
notify{"notsosecret: ${notsosecret}":}
