# == Defines jboss_admin::resource::mod_cluster_config
#
# Configures the mod-cluster-config subsystem.
#
# === Parameters
#
# [*proxy_list*]
#   Defines the list of mod cluster proxies to connect to.
#   Required.
#
# [*connector*]
#   The connector to connect to the mod cluster proxies with.
#   Valid values are: [ajp, http, https]
#   Required.
#
# [*balanacer*]
#   The name of the balancer on the mod cluster proxies to assoicate with.
#   Required.
#
define jboss_admin::resource::mod_cluster_config (
  $server,
  $proxy_list = undef,
  $connector  = undef,
  $balancer   = undef,
  $ensure     = present,
  $path       = $name
) {
  if $ensure == present {
    if $proxy_list == undef { fail('The attribute proxy_list is undefined by required') }
    if $connector == undef { fail('The attribute connector is undefined by required') }
    if $balancer == undef { fail('The attribute balancer is undefined by required') }

    validate_array($proxy_list)
    validate_re($connector, [ '^ajp', '^http', '^https']) 
    validate_string($balancer)

    $raw_options = { 
      'proxy-list' => join($proxy_list, ','),
      'connector'  => $connector,
      'balancer'   => $balancer,
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
