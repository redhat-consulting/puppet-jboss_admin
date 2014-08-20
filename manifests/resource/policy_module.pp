# == Defines jboss_admin::policy_module
#
# List of authentication modules
#
# === Parameters
#
# [*code*]
#   Class name of the module to be instantiated.
#
# [*flag*]
#   The flag controls how the module participates in the overall procedure. Allowed values are requisite, required, sufficient or optional.
#
# [*module*]
#   Name of JBoss Module where the login module is located.
#
# [*module_options*]
#   List of module options containing a name/value pair.
#
#
define jboss_admin::resource::policy_module (
  $server,
  $code                           = undef,
  $flag                           = undef,
  $module                         = undef,
  $module_options                 = undef,
  $ensure                         = present,
  $path                           = $name
) {
  if $ensure == present {

  

    $raw_options = { 
      'code'                         => $code,
      'flag'                         => $flag,
      'module'                       => $module,
      'module-options'               => $module_options,
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
