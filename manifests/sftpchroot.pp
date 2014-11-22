# Define: ssh::sftpchroot
#
# A defined type for managing sftp only chroots using the ssh internal-sftp feature.
#
# Features:
#   - Creates a preconfigured Match conditional block for the specified criteria.
#   - Ensures the ownership of the target chroot directory
#
# Parameters
#
# match  
#   Specify the conditional block criteria. The available criteria are User, Group, Host, LocalAddress, LocalPort, and Address.
#
# chroot_dir  
#   Pathname of a directory to chroot to after authentication.
#
# user_dir  
#   Name of the user/group writable and owned directory, default: $chrootdir/incoming.
#
# manage_home  
#   Ensure presence (creation) and ownership of the chroot directory, default: false.
#
# manage_user  
#   Ensure user account and posix group creation, default: false.
#
# uid  
#   Set the numerical value of the user's ID (only used if "manage_user" is set to true).
#
# gid  
#   Set the value of the group's ID (used for chroot_directory onwership and user account creation), default: sftponly.
#
# mode  
#   Set the default mode for user's writable and owned directory (see: user_dir), default: 0755.
#
# user_hash  
#   Set the already encrypted password (hash) for the given user account (only used if "manage_user" is set to true).
#
# user_key  
#   Set the ssh key in $home_dir/.ssh/ssh_authorized_keys for the given user account (only used if "manage_user" is set to true).
#
# user_keytype  
#   Specifyt the default ssh key type for a given ssh key (only used if "manage_user" is set to true), default: rsa.
#
# template  
#   Path of the custom template to use as sftpchroot snippet.
#
# Examples
#
#  class { 'ssh::server':
#    ..
#    subsystem_sftp => 'internal-sftp',
#  }
#
#  ssh::sftpchroot {
#    "sftponly":
#      chroot_dir  => '/home/sftponly',
#      match       => 'Group',
#      manage_home => true,
#      gid         => 'sftponly',
#  }
#
#  ssh::sftpchroot {
#    "developers":
#      chroot_dir  => '/home/%u',
#      match       => 'Group',
#  }
#
#  ssh::sftpchroot {
#    "foobar":
#      match       => 'User',
#      chroot_dir  => '/home/foobar',
#      manage_user => true,
#      manage_home => true,
#      uid         => 1000,
#      gid         => 'baz',
#      user_hash   => '$1$r615.TWc$sUjNpkE.StkuKW2PqTrFw.',
#      template    => 'puppet:///path/to/sftpcustom.erb',
#  }
#
# Will create and append the following configuration to the sshd_config file:
#
# ## sftp chroot for: Group sftponly
# Match Group sftponly
#     ChrootDirectory /home/sftponly
#     ForceCommand internal-sftp
#     X11Forwarding no
#     AllowTcpForwarding no
#
# ## sftp chroot for: Group developers
# Match Group developers
#     ChrootDirectory /home/%u
#     ForceCommand internal-sftp
#     X11Forwarding no
#     AllowTcpForwarding no
#
# ## sftp chroot for: User foobar
# Match User foobar
#     ChrootDirectory /home/foobar
#     ForceCommand internal-sftp
#     X11Forwarding no
#     AllowTcpForwarding no
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#

define ssh::sftpchroot ( 
  $match=undef,
  $chroot_dir=undef,
  $user_dir=undef,
  $manage_user=false,
  $manage_home=false,
  $uid=undef,
  $gid=undef,
  $mode=undef,
  $user_hash=undef,
  $user_key=undef,
  $user_keytype='rsa',
  $template=undef,
) {
# include ssh::server

  if ($match == undef) {
    err( "Invalid value given for match, must be one of: User, Group, Host, LocalAddress, LocalPort, Address." )
  }

  if ($match =~ /(?i-mx:user)/) and ($user_hash == undef or $user_key == undef) {
      err( "Invalid password specified for user ${chroot_user}: Specify a valid password or ssh key." )
  }

  if $chroot_dir == undef {
    err( "Invalid value given for chroot_dir: Specify a valid path." )
  }

  $my_gid = $gid ? {
    undef   => 'sftponly',
    default => $gid,
  }
  $my_mode = $mode ? {
    undef   => '0755',
    default => $mode,
  }
  $my_template = $template ? {
    undef   => 'ssh/sftpchroot.erb',
    default => $template,
  }
  $my_user_dir = $user_dir ? {
    undef   => 'incoming',
    default => $user_dir,
  }

  if $manage_user {
    if ! defined(Group[$gid]) {
      group {
        $gid:
          ensure  => present,
      }
    }

    user {
      $title:
        ensure     => present,
        comment    => 'Managed by puppet - sftp only chrooted account',
        home       => $chroot_dir,
        shell      => '/bin/false',
        uid        => $my_uid,
        gid        => $my_gid,
        expiry     => absent,
        managehome => false,
        password   => $user_hash,
        require    => Group[$gid];
    }

    if $user_key != undef {
      file {
        "${chroot_dir}/.ssh":
          ensure  => directory,
          owner   => $title,
          group   => $my_gid,
          mode    => '0644',
          require => File["${chroot_dir}"];
      }
      ssh_authorized_key {
        "${title}_ssh_key":
          ensure   => present,
          key      => $user_key,
          type     => $user_keytype,
          user     => $title,
          require  => File["$chroot_dir"];
      }
    }
  }

  if $manage_home {
    file { 
      "${chroot_dir}":
        ensure => directory,
        owner  => $ssh::params::sshd_owner,
        group  => $ssh::params::sshd_group,
        mode   => '0755';
      "${chroot_dir}/${my_user_dir}":
        ensure  => directory,
        owner   => $title,
        group   => $my_gid,
        mode    => $my_mode,
        recurse => true,
        require => File[$chroot_dir];
    }
  }

  concat::fragment { "sshd_config_fragment_chroot_${title}":
    target  => $ssh::params::sshd_config,
    content => template($my_template),
    order   => '10',
  }
}
