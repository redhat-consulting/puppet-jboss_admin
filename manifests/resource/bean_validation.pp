# == Defines jboss_admin::bean_validation
#
# Bean validation (JSR-303) for resource adapters
#
# === Parameters
#
# [*enabled*]
#   Specify whether bean validation is enabled
#
#
define jboss_admin::resource::bean_validation (
  $server,
  $enabled                        = undef,
  $ensure                         = present,
  $path                           = $name
) {
  if $ensure == present {

  

    $raw_options = { 
      'enabled'                      => $enabled,
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
