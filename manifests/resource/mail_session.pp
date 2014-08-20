# == Defines jboss_admin::mail_session
#
# Mail session definition
#
# === Parameters
#
# [*debug*]
#   Enables javamail debugging
#
# [*from*]
#   From address that is used as default from, if not set when sending
#
# [*jndi_name*]
#   JNDI name to where mail session should be bound
#
#
define jboss_admin::resource::mail_session (
  $server,
  $debug                          = undef,
  $from                           = undef,
  $jndi_name                      = undef,
  $ensure                         = present,
  $path                           = $name
) {
  if $ensure == present {

  

    $raw_options = { 
      'debug'                        => $debug,
      'from'                         => $from,
      'jndi-name'                    => $jndi_name,
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
