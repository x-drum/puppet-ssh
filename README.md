puppet-ssh
==========

This module manages openssh.

## Class: ssh::server

A class for managing sshd server options
Features:
  * Ensures sshd_config file is present.
  * Configures some sane defaults.

### Parameters

[*port*]  
Specifies the port on which the server listens for connections, (default 22).

[*listen_address*]  
Specifies the local addresses sshd(8) should listen on, (default 0.0.0.0).

[*allowed_users*]  
Allow only the following logins (usernames not numerical uids) matching this list.

[*allowed_groups*]  
Allow only users whose primary/additional group matches this list.

[*deny_users*]  
Deny the following logins (usernames not numerical uids) matching this list.

[*deny_groups*]  
Deny users whose primary/additional group matches this list.

[*syslog_facility*]  
Logging facility used when logging messages, (default AUTH).

[*loglevel*]  
Verbosity level used when logging messages, (default INFO).

[*permit_root_login*]  
Specifies whether root can log in using ssh [yes, without-password, forced-commands-only] (default yes).

[*password_authentication*]  
Specifies whether password authentication is allowed, (default yes).

[*allow_tcp_forwarding*]  
Specifies whether TCP forwarding is permitted, (default no).

[*x11_forwarding*]  
Specifies whether X11 forwarding is permitted, (default no).

[*use_pam*]  
Enables the Pluggable Authentication Module interface, (default yes).

[*use_dns*]  
Lookup remote hostname and check remote IP Address, (default yes).

[*subsystem_sftp*]  
Define the “sftp” file transfer subsystem, (default /usr/libexec/openssh/sftp-server).

### Examples

```
 class { 'ssh::server':
   permit_root_login       => 'without-password',
   password_authentication => 'no'
   port                    => 4444,
 }
```
```
 ssh::server_register { "UsePrivilegeSeparation":
   value => "sandbox",
   order => '03',
 }
```

## Define: ssh::client

A defined type for managing ssh client options
Features:
* Setting various options

### Parameters

[*params*]
 all possible and allowed parameters in key => value format

### Examples
```
  ssh::client {
    'client.domain.tld':
     params => { 
       'SendEnv' => 'LANG LC_*',
       'GSSAPIAuthentication' => 'no',
     },
   }
```

> Will produce the following ssh_config file:  
>  Host *  
>>  SendEnv LANG LC_*  
>>  GSSAPIAuthentication no  


## Define: ssh::authorized_keys
A defined type for managing ssh authorized keys for a given user.
Features:
  * Creates homedir if requested.
  * Can manage different keys for a single account/file.

### Parameters
[*path*]  
  Pass a non standard homedirectory path (eg: for root), default: empty.

[*keys*]  
  array of ssh keys in the canonic form (eg: ssh-rsa AAABBBCCC user@host ).

[*ensure*]  
  Ensure the presence of the given autorized_keys file, default: present.

[*manage_home*]  
  Enable home directory management, default: false.

## Examples
```
ssh::authorized_keys {
'root':
    path => '/root',
    keys => [
       'ssh-rsa AAABBBCCC user1@host',
       'ssh-rsa DDDEEEFFF user2@host'
    ],
}
```
## Define: ssh::sftpchroot

A defined type for managing sftp only chroots using the ssh internal-sftp feature.

Features:
  * Creates a preconfigured Match conditional block for the specified criteria.
  * Ensures the ownership of the target chroot directory

### Parameters

[*match*]  
  Specify the conditional block criteria. The available criteria are User, Group, Host, LocalAddress, LocalPort, and Address.

[*chroot_dir*]  
  Pathname of a directory to chroot to after authentication.

[*user_dir*]  
  Name of the user/group writable and owned directory, default: $chrootdir/incoming.

[*manage_home*]  
  Ensure presence (creation) and ownership of the chroot directory, default: false.

[*manage_user*]  
  Ensure user account and posix group creation, default: false.

[*uid*]  
  Set the numerical value of the user's ID (only used if "manage_user" is set to true).

[*gid*]  
  Set the value of the group's ID (used for chroot_directory onwership and user account creation), default: sftponly.

[*mode*]  
  Set the default mode for user's writable and owned directory (see: user_dir), default: 0755.

[*user_hash*]  
  Set the already encrypted password (hash) for the given user account (only used if "manage_user" is set to true).

[*user_key*]  
  Set the ssh key in $home_dir/.ssh/ssh_authorized_keys for the given user account (only used if "manage_user" is set to true).

[*user_keytype*]  
  Specifyt the default ssh key type for a given ssh key (only used if "manage_user" is set to true), default: rsa.

[*template*]  
  Path of the custom template to use as sftpchroot snippet.

### Examples

```
 class { 'ssh::server':
   ..
   subsystem_sftp => 'internal-sftp',
 }
```

```
 ssh::sftpchroot {
   "sftponly":
     chroot_dir  => '/home/sftponly',
     match       => 'Group',
     manage_home => true,
     gid         => 'sftponly',
 }
```
```
 ssh::sftpchroot {
   "developers":
     chroot_dir  => '/home/%u',
     match       => 'Group',
 }
```
```
 ssh::sftpchroot {
   "foobar":
     match       => 'User',
     chroot_dir  => '/home/foobar',
     manage_user => true,
     manage_home => true,
     uid         => 1000,
     gid         => 'baz',
     user_hash   => '$1$r615.TWc$sUjNpkE.StkuKW2PqTrFw.',
     template    => 'puppet:///path/to/sftpcustom.erb',
 }
```

> Will create and append the following configuration to the sshd_config file:

```
## sftp chroot for: Group sftponly
Match Group sftponly
    ChrootDirectory /home/sftponly
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no

## sftp chroot for: Group developers
Match Group developers
    ChrootDirectory /home/%u
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no

## sftp chroot for: User foobar
Match User foobar
    ChrootDirectory /home/foobar
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no
```

### Copyright:
Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
