# Class: ssh::config
#
# A class for managing ssh configuration.
#
# Requires:
# puppetlabs-concat
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class ssh::config inherits ssh::params {

  concat { $ssh::params::sshd_config:
    owner => $ssh::params::sshd_owner,
    group => $ssh::params::sshd_group,
    mode  => '0600',
  }

  concat::fragment{ 'sshd_config_header':
    target => $ssh::params::sshd_config,
    content => template('ssh/header.erb'),
    order => '00',
  }
  concat::fragment{ 'sshd_config_footer':
    target  => $ssh::params::sshd_config,
    content => "",
    order   => '99',
  }

  concat { $ssh::params::ssh_config:
    owner => $ssh::params::sshd_owner,
    group => $ssh::params::sshd_group,
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
  concat::fragment{ 'ssh_config_footer':
    target  => $ssh::params::ssh_config,
    content => "",
    order   => '99',
  }
}
