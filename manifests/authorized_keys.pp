
# == Define: ssh::authorized_keys
#
# A defined type for managing ssh authorized keys for a given user.
#
# Features:
#   * Creates homedir if requested.
#   * Can manage different keys for a single account/file.
#
# === Parameters
#
# [*path*]  
#   Pass a non standard homedirectory path (eg: for root), default: empty.
#
# [*keys*]  
#   array of ssh keys in the canonic form (eg: ssh-rsa AAABBBCCC user@host ).
#
# [*ensure*]
#   Ensure the presence of the given autorized_keys file, default: present.
#   
# [*manage_home*]  
#   Enable home directory management, default: false.
#
# === Examples
#
#    ssh::authorized_keys {
#    'root':
#        path => '/root',
#        keys => [
#           'ssh-rsa AAABBBCCC user1@host',
#           'ssh-rsa DDDEEEFFF user2@host'
#        ],
#    }
#
# === Copyright
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#

define ssh::authorized_keys (
  $path="",
  $keys,
  $ensure="present",
  $manage_home="false",
) {
  $mypath = $path ? {"" => "/home/${title}", default => $path}

  if empty($keys) == "true" {
    fail('Error: provide at least one ssh key.')
  }

  if $manage_home == "true" {
    if !defined(File[$mypath]) {
      file { $mypath:
        ensure => "directory",
        owner  => $title,
        mode   => 700,
      }
    }
  }

  file {
    "${mypath}/.ssh":
      ensure => "directory",
      owner  => $title,
      mode   => 700;
    "${mypath}/.ssh/authorized_keys":
      ensure  => $ensure,
      owner   => $title,
      mode    => 600,
      content => inline_template("# HEADER: Warning: This file is managed by puppet,\n# HEADER: do *not* edit.\n<% keys.each do |k| -%>\n<%= k %>\n<% end -%>");
  }
}
