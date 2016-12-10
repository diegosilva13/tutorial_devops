class mysql::client{
  package{"mysql-client":
    ensure => installed,
    require => Exec["apt-update"]
  }
}