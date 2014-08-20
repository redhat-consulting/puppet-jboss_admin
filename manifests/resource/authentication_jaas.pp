# == Defines jboss_admin::authentication_jaas
#
# Configuration to use a JAAS LoginContext to authenticate the users.
#
# === Parameters
#
# [*assign_groups*]
#   Map the roles loaded by JAAS to groups.
#
# [*resource_name*]
#   The name of the JAAS configuration to use.
#
#
define jboss_admin::resource::authentication_jaas (
  $server,
  $assign_groups                  = undef,
  $resource_name                  = undef,
  $ensure                         = present,
  $path                           = $name
) {
  if $ensure == present {

  

    $raw_options = { 
      'assign-groups'                => $assign_groups,
      'name'                         => $resource_name,
    }
    $options = delete_undef_values($raw_options)

    jboss_resource { $path:
      ensure  => $ensure,
      server  => $server,
      options => $options
    }


  }

  if $ensure == absent {
    jboss_resource { $path:
      ensure => $ensure,
      server => $server
    }
  }


}
