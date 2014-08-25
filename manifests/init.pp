# == Class: ssh::config
#
# A class for managing ssh configuration.
#
# Requires:
# puppetlabs-apache
#
# === Copyright
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class ssh::config inherits ssh::params {

  concat { $ssh::params::sshd_config:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment{ 'sshd_config_header':
    target => $ssh::params::sshd_config,
    content => template('ssh/header.erb'),
    order => '00',
  }

  concat { $ssh::params::ssh_config:
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment{ 'ssh_config_header':
    target  => $ssh::params::ssh_config,
    content => template('ssh/header.erb'),
    order   => '00',
  }

  concat::fragment{ 'ssh_config_template':
    target  => $ssh::params::ssh_config,
    content => "",
    order   => '01',
  }
}
