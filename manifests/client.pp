# == Define: ssh::client
#
# A defined type for managing ssh client options
# Features:
#   * Setting various options
#
# === Parameters
#
# [*params*]
#   all possible and allowed parameters in key => value format
#
# === Examples
#
#  ssh::client {
#    'client.domain.tld':
#     params => { 
#       'SendEnv' => 'LANG LC_*',
#       'GSSAPIAuthentication' => 'no',
#     },
#   }
#
# Will produce the following ssh_config file:
#  Host *
#    SendEnv LANG LC_*
#    GSSAPIAuthentication no
#
# === Copyright
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#

define ssh::client ( $params={} ) {
  include ssh::config

  concat::fragment { "ssh_config_fragment_${title}":
    target  => $ssh::params::ssh_config,
    content => template('ssh/ssh_config.erb'),
    order   => '20',
  }
}

