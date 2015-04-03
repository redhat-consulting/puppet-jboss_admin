# = Define jboss_admin::module
#
# Creates the file structure for a module, including the module.xml, 
# and manages the resource jar.
#
# = Parameters
#
# [*is_directory*]
#  true if the *resource_path* is a directory so recusivly copy all directory contents to the module.
#  false if the *resource_path* is a single file so copy that single file to the module.
#  Defaults to false.
#
# = Example
#
#  jboss_admin::module{ 'com.mysql':
#    ensure        => present,
#    server        => standalone,
#    resource_path => '/tmp/mysql-connector-java-5.1.29.jar',
#    dependencies  => ['javax.api', 'javax.transaction.api'],
#  }
#
define jboss_admin::module (
  $server,
  $resource_path,
  $is_directory = false,
  $dependencies = [],
  $namespace    = $name,
  $ensure       = present
) {
  $server_ref       = "Jboss_admin::Server[${server}]"
  $server_base_path = getparam($server_ref, 'base_path')
  $server_user      = getparam($server_ref, 'user')
  $server_group     = getparam($server_ref, 'group')
  $module_path      = "${server_base_path}/modules"
  $namespace_path   = regsubst($namespace, '\.', '/', 'G')
  $dir_path         = "${module_path}/${namespace_path}/main"

  File {
    owner => $server_user,
    group => $server_group
  }

  # collect all of the namespace parent directories
  $_namespace_parent_dirs_str = inline_template("<%=
    parent_dirs = []
    parent_dir  = \"${namespace_path}\"
    while parent_dir != '/' && parent_dir != '.'
      parent_dirs.push(\"${module_path}/\" + parent_dir)
      parent_dir = File.dirname(parent_dir)
    end
    parent_dirs.to_yaml
  %>")
  $_namespace_parent_dirs = parseyaml($_namespace_parent_dirs_str)

  # create namespace parent directories to module
  # NOTE: use ensure_resource because mutliple modules can have the
  #       same parent directories so this prevents duplicate resource declaration
  ensure_resource('file', $_namespace_parent_dirs, {
    'ensure' => 'directory',
    'owner'  => $server_user,
    'group'  => $server_group
  })
  
  # if the module contents is a directory
  # else if is single file, such as a jar
  if $is_directory {
    $resource_name = '.'

    file { "${dir_path}":
      ensure  => directory,
      source  => $resource_path,
      recurse => true,
      purge   => true,
    }
  } else {
    $resource_name = inline_template('<%= File.basename(@resource_path) %>')

    file { "${dir_path}":
      ensure  => directory,
    }
    file { "${dir_path}/${resource_name}":
      ensure  => file,
      source  => $resource_path
    }
  }

  # create the module deffinition file
  file { "${dir_path}/module.xml":
    ensure   => file,
    content  => template('jboss_admin/module.erb')
  }
}
