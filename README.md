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

### Copyright:
Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
