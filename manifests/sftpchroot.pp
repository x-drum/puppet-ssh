# == Define: ssh::sftpchroot
#
# A defined type for managing sftp only chroots using the ssh internal-sftp feature.
#
# Features:
#   * Creates a preconfigured Match conditional block for the specified criteria.
#   * Ensures the ownership of the target chroot directory
#
# === Parameters
#
# [*chroot_dir*]  
#   Pathname of a directory to chroot to after authentication.
#
# [*match*]  
#   Specify the conditional block criteria. The available criteria are User, Group, Host, LocalAddress, LocalPort, and Address.
#
# [*chroot_user*]  
#   Ensure user ownership of the chroot directory (usually set to the user running sshd).
#   
# [*chroot_group*]  
#   Ensure group ownership of the chroot directory (usually set to an unprivileged group).
#
#
# === Examples
#
#  ssh::sftpchroot {
#    "sftponly_users":
#      chroot_dir   => '/var/empty',
#      match        => 'Group sftpusers',
#      chroot_user  => 'root',
#      chroot_group => 'sftponly',
#  }
#
# Will append the following configuration to an existing sshd_config file:
#
# ## sftponly_users
# Match Group sftpusers
#     ChrootDirectory /var/empty
#     ForceCommand internal-sftp
#     X11Forwarding no
#     AllowTcpForwarding no
#
# === Copyright
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#

define ssh::sftpchroot ( 
  $chroot_dir=undef,
  $match=undef,
  $chroot_user='root',
  $chroot_group='nobody',
) {
  include ssh::server

  if $match == undef {
    err( "invalid value given for match: Must be 'Group foo' or 'User foo' ." )
  }
  if $chroot_dir == undef {
    err( "invalid value given for match: Must be 'Group foo' or 'User foo' ." )
  }

  if $manage_user {
    file { "${chroot_dir}":
      ensure => directory,
      owner  => $chroot_user,
      group  => $chroot_group,
      mode   => '0755',
    }
    user { "$":
      comment => "First Last",
      home => "/home/$",
      ensure => present,
      #shell => "/bin/bash",
      #uid => '501',
      #gid => '20'
    }
  }

  concat::fragment { "sshd_config_fragment_chroot_${title}":
    target  => $ssh::params::sshd_config,
    content => template('ssh/sftpchroot.erb'),
    order   => '20',
  }
}
