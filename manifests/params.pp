# == Class: ssh::params
#
# A class for managing ssh configuration.
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class ssh::params (
  $sshd_config='/etc/ssh/sshd_config',
  $ssh_config='/etc/ssh/ssh_config',
  $ssh_known_hosts='/etc/ssh/ssh_known_hosts',
){
  case $::osfamily {
    debian: {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-client'
      $service_name = 'ssh'
      $subsystem_sftp = '/usr/lib/misc/sftp-server'

    }
    redhat: {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-clients'
      $service_name = 'sshd'
      $subsystem_sftp = '/usr/libexec/openssh/sftp-server'
    }
    default: {
      case $::kernel {
        FreeBSD: {
          $server_package_name = undef
          $client_package_name = undef
          $service_name = 'sshd'
          $subsystem_sftp = '/usr/libexec/sftp-server'
          $sshd_owner = 'root'
          $sshd_group = 'wheel'
        }
        default: {
          notice("Unsupported platform: ${::osfamily}/${::operatingsystem}")
          $server_package_name = 'openssh'
          $client_package_name = 'openssh'
          $service_name = 'sshd'
          $subsystem_sftp = '/usr/lib/misc/sftp-server'
          $sshd_owner = 'root'
          $sshd_group = 'root'
        }
      }
    }
  }
}
