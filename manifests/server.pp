# Class: ssh::server
#
# A class for managing sshd server options
# Features:
#   - Ensures sshd_config file is present.
#   - Configures some sane defaults.
#
# Parameters
#
# port  
# Specifies the port on which the server listens for connections, (default 22).
#
# listen_address*  
# Specifies the local addresses sshd(8) should listen on, (default 0.0.0.0).
#
# allowed_users  
# Allow only the following logins (usernames not numerical uids) matching this list.
#
# allowed_groups  
# Allow only users whose primary/additional group matches this list.
#
# deny_users  
# Deny the following logins (usernames not numerical uids) matching this list.
#
# deny_groups  
# Deny users whose primary/additional group matches this list.
#
# syslog_facility  
# Logging facility used when logging messages, (default AUTH).
#
# loglevel  
# Verbosity level used when logging messages, (default INFO).
#
# permit_root_login  
# Specifies whether root can log in using ssh [yes, without-password, forced-commands-only] (default yes).
#
# password_authentication  
# Specifies whether password authentication is allowed, (default yes).
#
# allow_tcp_forwarding  
# Specifies whether TCP forwarding is permitted, (default no).
#
# x11_forwarding  
# Specifies whether X11 forwarding is permitted, (default no).
#
# use_pam  
# Enables the Pluggable Authentication Module interface, (default yes).
#
# use_dns  
# Lookup remote hostname and check remote IP Address, (default yes).
#
# subsystem_sftp  
# Define the sftp file transfer subsystem, (default /usr/libexec/openssh/sftp-server).
#
# Examples
#
#  class { 'ssh::server':
#    permit_root_login       => 'without-password',
#    password_authentication => 'no'
#    port                    => 4444,
#  }
#
#  ssh::server_register { "UsePrivilegeSeparation":
#    value => "sandbox",
#    order => '03',
#  }
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#

class ssh::server(
  $port='22',
  $listen_address='0.0.0.0',
  $allow_users=[],
  $allow_groups=[],
  $deny_users=[],
  $deny_groups=[],
  $syslog_facility='auth',
  $loglevel='info',
  $permit_root_login='no',
  $password_authentication='yes',
  $allow_tcp_forwarding='no',
  $x11_forwarding='no',
  $use_pam='yes',
  $use_dns='yes',
  $subsystem_sftp=$ssh::params::subsystem_sftp,
) inherits ssh::params {
  include ssh::config

  if $ssh::params::server_package_name {
    package { $ssh::params::server_package_name:
      ensure => present,
    }
  }

  concat::fragment{ 'sshd_config_template':
    target  => $ssh::params::sshd_config,
    content => template('ssh/sshd_config.erb'),
    order   => '01',
  }

  service { 'ssh':
    ensure     => running,
    name       => $ssh::params::service_name,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File[$ssh::params::sshd_config],
    require    => File['/etc/ssh/sshd_config'],
  }
}

## Allow external modules to add sshd configuration directives
define ssh::server_register( $value="", $order=30) {
  if ($value == "") or (value == undef) {
    err("Supply a valid sshd_config value for keyword ${name}")
  }

  concat::fragment{ "sshd_config_fragment_register_$name":
    target  => $ssh::params::sshd_config,
    content => inline_template("<%= @name %> <%= @value %>\n\n"),
    order   => $order
  }
}
