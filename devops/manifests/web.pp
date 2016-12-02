include mysql::client
include tomcat::server

$keystore_file = "/etc/ssl/.keystore"
$ssl_connector = {
  "port"         => 8443,
  "protocol"     => "HTTP/1.1",
  "SSLEnabled"   => true,
  "maxThreads"   => 150,
  "scheme"       => "https",
  "secure"       => "true",
  "keystoreFile" => $keystore_file,
  "keystorePass" => "secret",
  "clientAuth"   => false,
  "sslProtocol"  => "SSLv3",
}

file { $keystore_file:
  mode   => 0644,
  source => "/vagrant/manifests/.keystore",
}

file { "/var/lib/tomcat7/conf/.keystore":
  owner   => root,
  group   => tomcat7,
  mode    => 0640,
  source  => "/vagrant/manifests/.keystore",
  require => Package["tomcat7"],
  notify  => Service["tomcat7"]
}

file { "/var/lib/tomcat7/conf/server.xml":
  owner   => root,
  group   => tomcat7,
  mode    => 0644,
  source  => "puppet:///modules/tomcat/server.xml",
  require => Package["tomcat7"],
  notify  => Service["tomcat7"]
}

$db_host = "192.168.33.10"
$db_schema = "loja_schema"
$db_user = "loja"
$db_password = "lojasecret"

file { "/var/lib/tomcat7/conf/context.xml":
  owner   => root,
  group   => tomcat7,
  mode    => 0644,
  content => template("tomcat/context.xml"),
  require => Package["tomcat7"],
  notify  => Service["tomcat7"],
}

file { "/var/lib/tomcat7/webapps/devopsnapratica.war":
  owner   => tomcat7,
  group   => tomcat7,
  mode    => 0644,
  source  => "/vagrant/manifests/devopsnapratica.war",
  require => Package["tomcat7"],
  notify  => Service["tomcat7"],
}

class { "tomcat::server":
  connectors   => [$ssl_connector],
  data_sources => {
    "jdbc/web"     => $db,
    "jdbc/secure"  => $db,
    "jdbc/storage" => $db,
  }
  ,
  require      => File[$keystore_file]
}

$db = {
  "user"     => "loja",
  "password" => "lojasecret",
  "driver"   => "com.mysql.jdbc.Driver",
  "url"      => "jdbc:mysql://192.168.33.10:3306/loja_schema",
}
