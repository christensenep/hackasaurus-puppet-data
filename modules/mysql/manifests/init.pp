# Much of this code is taken from:
# http://bitfieldconsulting.com/puppet-and-mysql-create-databases-and-users

class mysql {
  package { 'mysql-server-5.1':
    ensure => present,
  }

  service { 'mysql':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package['mysql-server-5.1']
  }
  
  exec { 'set-mysql-password':
    unless => "mysqladmin -uroot -p$mysql_password status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $mysql_password",
    require => Service['mysql'],
  }
  
  define db( $user, $password ) {
    include mysql
    
    exec { "create-${name}-db":
      unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
      command => "/usr/bin/mysql -uroot -p$mysql_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
      require => Exec['set-mysql-password']
    }
  }
}
